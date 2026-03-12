package customer.inventory_service.handler;

import com.sap.cds.services.handler.EventHandler;
import com.sap.cds.services.handler.annotations.On;
import com.sap.cds.services.handler.annotations.ServiceName;
import com.sap.cds.services.ErrorStatuses;
import com.sap.cds.services.ServiceException;

import com.sap.cloud.sdk.cloudplatform.connectivity.DestinationAccessor;
import com.sap.cloud.sdk.cloudplatform.connectivity.HttpDestination;
import com.sap.cloud.sdk.cloudplatform.connectivity.HttpClientAccessor;

import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.util.EntityUtils;
import org.apache.http.HttpResponse;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import cds.gen.trackingservice.TrackingService_;
import cds.gen.trackingservice.GetAllTrackingsContext;
import cds.gen.trackingservice.GetTrackingByIdContext;
import cds.gen.trackingservice.GetTrackingsByStatusContext;
import cds.gen.trackingservice.CreateTrackingContext;
import cds.gen.trackingservice.AddTimelineEventContext;

import cds.gen.tracemeds.tracking.TrackingRecord;
import cds.gen.tracemeds.tracking.CreateTrackingResponse;

import java.util.*;

@Component
@ServiceName(TrackingService_.CDS_NAME)
public class TrackingServiceHandler implements EventHandler {

    private static final Logger logger = LoggerFactory.getLogger(TrackingServiceHandler.class);
    private static final String DESTINATION_NAME = "rapid-track";
    private final ObjectMapper mapper = new ObjectMapper();

    // ── Destination helpers ──────────────────────────────────────────────────

    private HttpDestination getDestination() {
        return DestinationAccessor.getDestination(DESTINATION_NAME).asHttp();
    }

    private String getBaseUrl() {
        return getDestination().getUri().toString().replaceAll("/$", "");
    }

    // WHY: BTP Destination Additional Properties are NOT auto-forwarded as HTTP
    // headers — must read them manually and inject into every request
    private String getApiKey() {
        return getDestination().get("x-rapidapi-key")
                .map(Object::toString).getOrElse("");
    }

    private String getApiHost() {
        return getDestination().get("x-rapidapi-host")
                .map(Object::toString).getOrElse("");
    }

    // ── Request helpers ──────────────────────────────────────────────────────

    private HttpResponse executeGet(String url) throws Exception {
        HttpGet request = new HttpGet(url);
        request.setHeader("x-rapidapi-key", getApiKey());
        request.setHeader("x-rapidapi-host", getApiHost());
        logger.info(">>> GET {} | key={}...", url, getApiKey().substring(0, 8));
        return HttpClientAccessor.getHttpClient(getDestination()).execute(request);
    }

    private HttpResponse executePost(String url, String jsonBody) throws Exception {
        HttpPost request = new HttpPost(url);
        request.setHeader("Content-Type", "application/json");
        request.setHeader("x-rapidapi-key", getApiKey());
        request.setHeader("x-rapidapi-host", getApiHost());
        request.setEntity(new StringEntity(jsonBody));
        logger.info(">>> POST {} | body={}", url, jsonBody);
        return HttpClientAccessor.getHttpClient(getDestination()).execute(request);
    }

    // ── Type helpers ─────────────────────────────────────────────────────────

    // WHY: CAP generated create() takes NO args — create empty then putAll
    @SuppressWarnings("unchecked")
    private TrackingRecord toTrackingRecord(JsonNode node) {
        Map<String, Object> map = mapper.convertValue(node, Map.class);
        TrackingRecord record = TrackingRecord.create();
        record.putAll(map);
        return record;
    }

    // ── Handlers ─────────────────────────────────────────────────────────────

    @On(event = GetAllTrackingsContext.CDS_NAME)
    public void onGetAllTrackings(GetAllTrackingsContext context) {
        try {
            logger.info(">>> getAllTrackings called");
            String body = EntityUtils.toString(
                    executeGet(getBaseUrl() + "/tracking/").getEntity());
            logger.info(">>> RapidAPI response: {}", body);

            JsonNode data = mapper.readTree(body).get("data");
            List<TrackingRecord> result = new ArrayList<>();
            if (data != null && data.isArray())
                for (JsonNode item : data)
                    result.add(toTrackingRecord(item));

            context.setResult(result);
            context.setCompleted();
        } catch (Exception e) {
            logger.error("getAllTrackings failed", e);
            throw new ServiceException(ErrorStatuses.SERVER_ERROR, e.getMessage());
        }
    }

    @On(event = GetTrackingByIdContext.CDS_NAME)
    public void onGetTrackingById(GetTrackingByIdContext context) {
        try {
            String trackingId = context.getTrackingId();
            logger.info(">>> getTrackingById: {}", trackingId);

            String body = EntityUtils.toString(
                    executeGet(getBaseUrl() + "/tracking/" + trackingId).getEntity());
            logger.info(">>> RapidAPI response: {}", body);

            context.setResult(toTrackingRecord(mapper.readTree(body)));
            context.setCompleted();
        } catch (Exception e) {
            logger.error("getTrackingById failed", e);
            throw new ServiceException(ErrorStatuses.SERVER_ERROR, e.getMessage());
        }
    }

    @On(event = GetTrackingsByStatusContext.CDS_NAME)
    public void onGetTrackingsByStatus(GetTrackingsByStatusContext context) {
        try {
            String status = context.getStatus();
            logger.info(">>> getTrackingsByStatus: {}", status);

            String body = EntityUtils.toString(
                    executeGet(getBaseUrl() + "/tracking/?status=" + status).getEntity());
            logger.info(">>> RapidAPI response: {}", body);

            JsonNode data = mapper.readTree(body).get("data");
            List<TrackingRecord> result = new ArrayList<>();
            if (data != null && data.isArray())
                for (JsonNode item : data)
                    result.add(toTrackingRecord(item));

            context.setResult(result);
            context.setCompleted();
        } catch (Exception e) {
            logger.error("getTrackingsByStatus failed", e);
            throw new ServiceException(ErrorStatuses.SERVER_ERROR, e.getMessage());
        }
    }

    @SuppressWarnings("unchecked")
    @On(event = CreateTrackingContext.CDS_NAME)
    public void onCreateTracking(CreateTrackingContext context) {
        try {
            logger.info(">>> createTracking called");

            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("sender", context.getSender());
            payload.put("receiver", context.getReceiver());
            payload.put("packages", context.getPackages());
            payload.put("senderAddress", context.getSenderAddress());
            payload.put("receiverAddress", context.getReceiverAddress());
            payload.put("receiverAddressCountry", context.getReceiverAddressCountry());
            payload.put("receiverAddressState", context.getReceiverAddressState());
            payload.put("receiverAddressCity", context.getReceiverAddressCity());
            payload.put("receiverAddressDistricts", context.getReceiverAddressDistricts());
            payload.put("additionalInformation", context.getAdditionalInformation());

            String body = EntityUtils.toString(
                    executePost(getBaseUrl() + "/tracking/",
                            mapper.writeValueAsString(payload)).getEntity());
            logger.info(">>> RapidAPI createTracking response: {}", body);

            // WHY: create() no-arg → putAll map data
            Map<String, Object> responseMap = mapper.convertValue(
                    mapper.readTree(body), Map.class);
            CreateTrackingResponse resp = CreateTrackingResponse.create();
            resp.putAll(responseMap);

            context.setResult(resp);
            context.setCompleted();
        } catch (Exception e) {
            logger.error("createTracking failed", e);
            throw new ServiceException(ErrorStatuses.SERVER_ERROR, e.getMessage());
        }
    }

    @On(event = AddTimelineEventContext.CDS_NAME)
    public void onAddTimelineEvent(AddTimelineEventContext context) {
        try {
            String trackingId = context.getTrackingId();
            logger.info(">>> addTimelineEvent for: {}", trackingId);

            Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("status", context.getStatus());
            payload.put("location", context.getLocation());
            payload.put("description", context.getDescription());

            String body = EntityUtils.toString(
                    executePost(getBaseUrl() + "/tracking/" + trackingId + "/timeline/",
                            mapper.writeValueAsString(payload)).getEntity());
            logger.info(">>> RapidAPI addTimeline response: {}", body);

            context.setResult(toTrackingRecord(mapper.readTree(body)));
            context.setCompleted();
        } catch (Exception e) {
            logger.error("addTimelineEvent failed", e);
            throw new ServiceException(ErrorStatuses.SERVER_ERROR, e.getMessage());
        }
    }
}