namespace tracemeds.tracking;

type SenderReceiver {
    id    : String;
    name  : String;
    phone : String;
    email : String;
}

type Package {
    id          : String;
    name        : String;
    description : String;
    weight      : Decimal;
    height      : Decimal;
    width       : Decimal;
    length      : Decimal;
}

type AddressRef {
    id   : String;
    name : String;
}

type TimelineEvent {
    _id       : String;
    timestamp : String;
    status    : String;
    location  : String;
}

type TrackingRecord {
    _id                      : String;
    trackingId               : String;
    companyId                : String;
    date                     : String;
    lastUpdatedDate          : String;
    status                   : String;
    senderAddress            : String;
    receiverAddress          : String;
    additionalInformation    : String;
    packagesCount            : Integer;
    sender                   : SenderReceiver;
    receiver                 : SenderReceiver;
    packages                 : array of Package;
    timeline                 : array of TimelineEvent;
    receiverAddressCountry   : AddressRef;
    receiverAddressState     : AddressRef;
    receiverAddressCity      : AddressRef;
    receiverAddressDistricts : AddressRef;
}

type CreateTrackingResponse {
    message    : String;
    trackingId : String;
}
