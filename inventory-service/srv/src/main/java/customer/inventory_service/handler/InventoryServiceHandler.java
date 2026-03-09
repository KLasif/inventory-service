package customer.inventory_service.handler;

import cds.gen.inventoryservice.*;
import com.sap.cds.ql.*;
import com.sap.cds.ql.cqn.CqnSelect;
import com.sap.cds.ql.cqn.CqnUpdate;
import com.sap.cds.services.cds.*;
import com.sap.cds.services.handler.*;
import com.sap.cds.services.handler.annotations.*;
import com.sap.cds.services.persistence.PersistenceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
@ServiceName(InventoryService_.CDS_NAME)
public class InventoryServiceHandler implements EventHandler {

    @Autowired
    PersistenceService db;


    @Before(event = CqnService.EVENT_CREATE, entity = InventoryRecords_.CDS_NAME)
    public void beforeCreate(CdsCreateEventContext context, InventoryRecords record) {
        if (record.getQuantityOnHand()     == null) record.setQuantityOnHand(0);
        if (record.getReservedQuantity()   == null) record.setReservedQuantity(0);
        if (record.getDispatchedQuantity() == null) record.setDispatchedQuantity(0);
        if (record.getQuantity() != null) {
            record.setQuantityOnHand(record.getQuantity());
        }
    }

    // ─── ACTION: RESERVE ─────────────────────────────────────────────────────
    // NO second param — bound actions don't support entity injection in CAP 4.6.1

    @On(event = InventoryRecordsReserveContext.CDS_NAME, entity = InventoryRecords_.CDS_NAME)
    public void onReserve(InventoryRecordsReserveContext context) {
        Integer quantity = context.getQuantity();
        String id = extractId(context.getCqn().toString());
        InventoryRecords record = fetchRecord(id);

        int onHand    = toInt(record.getQuantityOnHand());
        int reserved  = toInt(record.getReservedQuantity());
        int available = onHand - reserved;

        if (quantity > available) {
            context.getMessages().error("Insufficient stock. Available: " + available);
            return;
        }

        record.setReservedQuantity(reserved + quantity);
        saveRecord(record);
        context.setResult(record);
    }


    @On(event = InventoryRecordsReleaseContext.CDS_NAME, entity = InventoryRecords_.CDS_NAME)
    public void onRelease(InventoryRecordsReleaseContext context) {
        Integer quantity = context.getQuantity();
        String id = extractId(context.getCqn().toString());
        InventoryRecords record = fetchRecord(id);

        int reserved = toInt(record.getReservedQuantity());

        if (quantity > reserved) {
            context.getMessages().error("Cannot release more than reserved: " + reserved);
            return;
        }

        record.setReservedQuantity(reserved - quantity);
        saveRecord(record);
        context.setResult(record);
    }

    // ─── ACTION: DISPATCH ────────────────────────────────────────────────────

    @On(event = InventoryRecordsDispatchContext.CDS_NAME, entity = InventoryRecords_.CDS_NAME)
    public void onDispatch(InventoryRecordsDispatchContext context) {
        Integer quantity = context.getQuantity();
        String id = extractId(context.getCqn().toString());
        InventoryRecords record = fetchRecord(id);

        int onHand     = toInt(record.getQuantityOnHand());
        int reserved   = toInt(record.getReservedQuantity());
        int dispatched = toInt(record.getDispatchedQuantity());

        if (quantity > reserved) {
            context.getMessages().error("Can only dispatch reserved stock. Reserved: " + reserved);
            return;
        }

        record.setQuantityOnHand(onHand - quantity);
        record.setQuantity(toInt(record.getQuantity()) - quantity);
        record.setReservedQuantity(reserved - quantity);
        record.setDispatchedQuantity(dispatched + quantity);
        saveRecord(record);
        context.setResult(record);
    }

    @On(event = InventoryRecordsAdjustStockContext.CDS_NAME, entity = InventoryRecords_.CDS_NAME)
    public void onAdjustStock(InventoryRecordsAdjustStockContext context) {
        Integer quantity = context.getQuantity();
        String  reason   = context.getReason();
        String id = extractId(context.getCqn().toString());
        InventoryRecords record = fetchRecord(id);

        int onHand   = toInt(record.getQuantityOnHand());
        int adjusted = onHand + quantity;

        if (adjusted < 0) {
            context.getMessages().error("Adjustment would result in negative stock.");
            return;
        }

        record.setQuantityOnHand(adjusted);
        record.setQuantity(adjusted);
        saveRecord(record);
        context.getMessages().info("Stock adjusted by " + quantity + ". Reason: " + reason);
        context.setResult(record);
    }

    private String extractId(String cqnString) {
        // Pattern: ID = 'some-uuid'
        int idIndex = cqnString.indexOf("ID = '");
        if (idIndex == -1) {
            idIndex = cqnString.indexOf("ID='");
            if (idIndex == -1) {
                throw new IllegalArgumentException("Cannot extract ID from CQN: " + cqnString);
            }
            idIndex += 4;
        } else {
            idIndex += 6;
        }
        int endIndex = cqnString.indexOf("'", idIndex);
        return cqnString.substring(idIndex, endIndex);
    }

    private InventoryRecords fetchRecord(String id) {
        CqnSelect query = Select.from(InventoryRecords_.class)
                .where(r -> r.ID().eq(id));
        return db.run(query)
                .first(InventoryRecords.class)
                .orElseThrow(() -> new IllegalArgumentException("Inventory record not found: " + id));
    }

    private void saveRecord(InventoryRecords record) {
        CqnUpdate update = Update.entity(InventoryRecords_.class).entry(record);
        db.run(update);
    }

    private int toInt(Integer value) {
        return value == null ? 0 : value;
    }
}