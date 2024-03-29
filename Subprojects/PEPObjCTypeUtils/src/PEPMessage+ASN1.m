//
//  PEPMessage+ASN1.m
//  pEpCC_macOS
//
//  Created by Dirk Zimmermann on 25.08.21.
//

#import "PEPMessage+ASN1.h"

#import <map_asn1.h>
#import <message_codec.h>
#import "PEPMessage+PEPConvert.h"

@implementation PEPMessage (ASN1)

+ (instancetype _Nullable)messageFromAsn1Data:(NSData *)asn1Data {
    ASN1Message_t *asn1Message = NULL;
    PEP_STATUS status = decode_ASN1Message_message(asn1Data.bytes, asn1Data.length, &asn1Message);
    if (status != PEP_STATUS_OK) {
        return nil;
    }

    message *msg = ASN1Message_to_message(asn1Message, NULL, YES, 0);

    free_ASN1Message(asn1Message);

    if (!msg) {
        return nil;
    }

    PEPMessage *messageToReturn = [PEPMessage fromStruct:msg];
    free_message(msg);
    return messageToReturn;
}

- (NSData *)asn1Data {
    message *msg = [self toStruct];
    ASN1Message_t *asn1Message = ASN1Message_from_message(msg, NULL, YES, 0);
    free_message(msg);

    if (asn1Message == NULL) {
        return nil;
    }

    char *msgBytes = NULL;
    size_t msgBytesSze = 0;
    PEP_STATUS status = encode_ASN1Message_message(asn1Message, &msgBytes, &msgBytesSze);

    free_ASN1Message(asn1Message);

    if (status != PEP_STATUS_OK) {
        return nil;
    }

    NSData *msgData = [[NSData alloc] initWithBytesNoCopy:msgBytes length:msgBytesSze freeWhenDone:YES];
    return msgData;
}

@end
