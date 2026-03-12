using {tracemeds.tracking} from './tracking-types';

@requires: 'authenticated-user'
service TrackingService {

    @(requires: [
        'InventoryManager',
        'SystemAdmin'
    ])
    function getAllTrackings()                             returns array of tracking.TrackingRecord;

    @(requires: [
        'InventoryManager',
        'SystemAdmin',
        'HospitalUser'
    ])
    function getTrackingById(trackingId: String)           returns tracking.TrackingRecord;

    @(requires: [
        'InventoryManager',
        'SystemAdmin',
        'HospitalUser'
    ])
    function getTrackingsByStatus(status: String)          returns array of tracking.TrackingRecord;

    @(requires: [
        'InventoryManager',
        'SystemAdmin'
    ])
    action   createTracking(sender: tracking.SenderReceiver,
                            receiver: tracking.SenderReceiver,
                            packages: array of tracking.Package,
                            senderAddress: String,
                            receiverAddress: String,
                            receiverAddressCountry: tracking.AddressRef,
                            receiverAddressState: tracking.AddressRef,
                            receiverAddressCity: tracking.AddressRef,
                            receiverAddressDistricts: tracking.AddressRef,
                            additionalInformation: String) returns tracking.CreateTrackingResponse;

    @(requires: [
        'InventoryManager',
        'SystemAdmin'
    ])
    action   addTimelineEvent(trackingId: String,
                              status: String,
                              location: String,
                              description: String)         returns tracking.TrackingRecord;
}
