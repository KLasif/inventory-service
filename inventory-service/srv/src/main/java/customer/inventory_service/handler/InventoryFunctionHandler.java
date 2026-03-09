package customer.inventory_service.handler;


import cds.gen.inventoryservice.*;
import com.sap.cds.ql.*;
import com.sap.cds.ql.cqn.CqnSelect;
import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.On;
import com.sap.cds.services.handler.annotations.ServiceName;
import com.sap.cds.services.persistence.PersistenceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Component
@ServiceName(InventoryService_.CDS_NAME)
public class InventoryFunctionHandler implements EventHandler {

    @Autowired
    PersistenceService db;

    @On(event = GetAvailableStockContext.CDS_NAME)
    public void onGetAvailableStock(GetAvailableStockContext context) {
        String productID = context.getProductID();
        String location  = context.getLocation();

        // SELECT * FROM InventoryRecords
        // WHERE product_productID = ? AND location = ? AND status = 'AVAILABLE'
        CqnSelect query = Select.from(InventoryRecords_.class)
                .where(r -> r.product_productID().eq(productID)
                        .and(r.location().eq(location))
                        .and(r.status().eq("AVAILABLE")));

        List<InventoryRecords> records = db.run(query)
                .listOf(InventoryRecords.class);

        // Sum up: available = quantity - reservedQuantity for each batch
        int available = records.stream()
                .mapToInt(r -> toInt(r.getQuantity()) - toInt(r.getReservedQuantity()))
                .sum();

        context.setResult(available);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FUNCTION: getExpiringBatches
    // Returns inventory records expiring within the given number of days
    // ─────────────────────────────────────────────────────────────────────────
    @On(event = GetExpiringBatchesContext.CDS_NAME)
    public void onGetExpiringBatches(GetExpiringBatchesContext context) {
        Integer withinDays = context.getWithinDays();

        LocalDate today     = LocalDate.now();
        LocalDate threshold = today.plusDays(withinDays);

        // SELECT * FROM InventoryRecords
        // WHERE expiryDate >= today AND expiryDate <= today + withinDays
        CqnSelect query = Select.from(InventoryRecords_.class)
                .where(r -> r.expiryDate().ge(today)
                        .and(r.expiryDate().le(threshold)))
                .orderBy(r -> r.expiryDate().asc());

        List<InventoryRecords> records = db.run(query)
                .listOf(InventoryRecords.class);

        context.setResult(records);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FUNCTION: getStockByLocation
    // Returns all inventory records for a given location
    // ─────────────────────────────────────────────────────────────────────────
    @On(event = GetStockByLocationContext.CDS_NAME)
    public void onGetStockByLocation(GetStockByLocationContext context) {
        String location = context.getLocation();

        // SELECT * FROM InventoryRecords
        // WHERE location = ? AND status = 'AVAILABLE'
        CqnSelect query = Select.from(InventoryRecords_.class)
                .where(r -> r.location().eq(location)
                        .and(r.status().eq("AVAILABLE")))
                .orderBy(r -> r.product_productID().asc());

        List<InventoryRecords> records = db.run(query)
                .listOf(InventoryRecords.class);

        context.setResult(records);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FUNCTION: getLowStockProducts
    // Returns products where total available quantity is below the threshold
    // ─────────────────────────────────────────────────────────────────────────
    @On(event = GetLowStockProductsContext.CDS_NAME)
    public void onGetLowStockProducts(GetLowStockProductsContext context) {
        Integer threshold = context.getThreshold();

        // Fetch all AVAILABLE inventory records with product info
        CqnSelect query = Select.from(InventoryRecords_.class)
                .columns(r -> r.product_productID(),
                         r -> r.productName(),
                         r -> r.location(),
                         r -> r.quantity(),
                         r -> r.reservedQuantity())
                .where(r -> r.status().eq("AVAILABLE"));

        List<InventoryRecords> records = db.run(query)
                .listOf(InventoryRecords.class);

        // Group by productID + location, sum available stock, filter below threshold
        List<GetLowStockProductsContext.ReturnType> result = records.stream()
                .collect(Collectors.groupingBy(
                        r -> r.getProductProductID() + "|" + r.getLocation()
                ))
                .entrySet().stream()
                .map(entry -> {
                    List<InventoryRecords> group = entry.getValue();
                    InventoryRecords first = group.get(0);

                    int currentStock = group.stream()
                            .mapToInt(r -> toInt(r.getQuantity()) - toInt(r.getReservedQuantity()))
                            .sum();

                    // Build return type using generated class
                    GetLowStockProductsContext.ReturnType row =
                            GetLowStockProductsContext.ReturnType.create();
                    row.setProductID(first.getProductProductID());
                    row.setProductName(first.getProductName());
                    row.setLocation(first.getLocation());
                    row.setCurrentStock(currentStock);
                    row.setThreshold(threshold);
                    return row;
                })
                .filter(row -> row.getCurrentStock() < threshold)
                .collect(Collectors.toList());

        context.setResult(result);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FUNCTION: getInventorySummary
    // Returns aggregated summary across all inventory records
    // ─────────────────────────────────────────────────────────────────────────
    @On(event = GetInventorySummaryContext.CDS_NAME)
    public void onGetInventorySummary(GetInventorySummaryContext context) {

        // Fetch all records with needed fields only
        CqnSelect query = Select.from(InventoryRecords_.class)
                .columns(r -> r.product_productID(),
                         r -> r.quantity(),
                         r -> r.reservedQuantity(),
                         r -> r.expiryDate(),
                         r -> r.status());

        List<InventoryRecords> records = db.run(query)
                .listOf(InventoryRecords.class);

        LocalDate thirtyDaysFromNow = LocalDate.now().plusDays(30);

        // Calculate all summary fields in one stream pass
        int totalQuantity      = 0;
        int availableQuantity  = 0;
        int reservedQuantity   = 0;
        int dispatchedQuantity = 0;
        int expiringIn30Days   = 0;

        for (InventoryRecords r : records) {
            int qty      = toInt(r.getQuantity());
            int reserved = toInt(r.getReservedQuantity());
            String status = r.getStatus();

            totalQuantity += qty;

            if ("AVAILABLE".equals(status)) {
                availableQuantity  += (qty - reserved);
                reservedQuantity   += reserved;
            } else if ("DISPATCHED".equals(status)) {
                dispatchedQuantity += qty;
            }

            // Count batches expiring within 30 days
            LocalDate expiry = r.getExpiryDate();
            if (expiry != null && !expiry.isBefore(LocalDate.now())
                    && !expiry.isAfter(thirtyDaysFromNow)) {
                expiringIn30Days++;
            }
        }

        // Count distinct products
        long totalProducts = records.stream()
                .map(InventoryRecords::getProductProductID)
                .distinct()
                .count();

        // Build return type using generated class
        GetInventorySummaryContext.ReturnType summary =
                GetInventorySummaryContext.ReturnType.create();
        summary.setTotalProducts((int) totalProducts);
        summary.setTotalQuantity(totalQuantity);
        summary.setAvailableQuantity(availableQuantity);
        summary.setReservedQuantity(reservedQuantity);
        summary.setDispatchedQuantity(dispatchedQuantity);
        summary.setExpiringIn30Days(expiringIn30Days);

        context.setResult(summary);
    }

    // ─── HELPER ──────────────────────────────────────────────────────────────

    private int toInt(Integer value) {
        return value == null ? 0 : value;
    }
}