//
//  PEPMessage+ASN1.m
//  pEpCC_macOS
//
//  Created by Dirk Zimmermann on 25.08.21.
//

#import "PEPMessage+ASN1.h"

#import "PEPObjCTypeUtils.h"
#import "map_asn1.h"
#import "message_codec.h"

@implementation PEPMessage (ASN1)

+ (instancetype _Nullable)messageFromAsn1Data:(NSData *)asn1Data
{
    ASN1Message_t *asn1Message = NULL;
    PEP_STATUS status = decode_ASN1Message_message(asn1Data.bytes, asn1Data.length, &asn1Message);
    if (status != PEP_STATUS_OK) {
        return nil;
    }

    message *msg = ASN1Message_to_message(asn1Message, NULL, YES, 0);

    // TODO: Use free_ASN1Message as soon as available (see ENGINE-969)
    ASN_STRUCT_FREE(asn_DEF_ASN1Message, asn1Message);

    if (!msg) {
        return nil;
    }

    return [PEPMessage fromStruct:msg];
}

- (NSData *)asn1Data
{
    message *msg = [self toStruct];
    ASN1Message_t *asn1Message = ASN1Message_from_message(msg, NULL, YES, 0);
    free_message(msg);

    if (asn1Message == NULL) {
        return nil;
    }

    char *msgBytes = NULL;
    size_t msgBytesSze = 0;
    PEP_STATUS status = encode_ASN1Message_message(asn1Message, &msgBytes, &msgBytesSze);

    // TODO: Use free_ASN1Message as soon as available (see ENGINE-969)
    ASN_STRUCT_FREE(asn_DEF_ASN1Message, asn1Message);

    if (status != PEP_STATUS_OK) {
        return nil;
    }

    NSData *msgData = [[NSData alloc] initWithBytesNoCopy:msgBytes length:msgBytesSze];

    return msgData;
}

@end

// MARK: - Test cases for ENGINE-970

//// TODO: Engine test case. Re-enable with ENGINE-970 having been fixed, verify, and then remove.
//char *pString(const char *pstrIn)
//{
//    const size_t maxSize = 256;
//    size_t inputSize = strnlen(pstrIn, maxSize);
//    char *pstrResult = malloc(inputSize + 1);
//    strncpy(pstrResult, pstrIn, inputSize + 1);
//    pstrResult[inputSize] = '\0';
//    return pstrResult;
//}
//
//// TODO: Engine test case. Re-enable with ENGINE-970 having been fixed, verify, and then remove.
//char *notSoRandomData(size_t dataLength)
//{
//    char *bytes = malloc(dataLength);
//
//    for (size_t i = 0; i < dataLength; ++i) {
//        bytes[i] = (i + 1) % 255;
//    }
//
//    return bytes;
//}
//
//// TODO: Engine test case. Re-enable with ENGINE-970 having been fixed, verify, and then remove.
//BOOL testCaseAsnEncodeMessageAttachment(void)
//{
//    // encode
//
//    pEp_identity *from = new_identity(pString("blah1@example.com"),
//                                      pString("0E12343434343434343434EAB3484343434343434"),
//                                      pString("user_id_1"),
//                                      pString("user_name_1"));
//
//    pEp_identity *to = new_identity(pString("blah2@example.com"),
//                                    pString("123434343434343C3434343434343734349A34344"),
//                                    pString("user_id_2"),
//                                    pString("user_name_2"));
//
//    message *msg1 = new_message(PEP_dir_outgoing);
//    msg1->from = from;
//    msg1->to = new_identity_list(to);
//    msg1->longmsg = pString("some text");
//    size_t dataSize = 50000;
//    char *data = notSoRandomData(dataSize);
//    msg1->attachments = new_bloblist(data, dataSize, "application/pgp-keys", "key.asc");
//
//    ASN1Message_t *asn1Message1 = ASN1Message_from_message(msg1, NULL, YES, 0);
//
//    if (asn1Message1 == NULL) {
//        return NO;
//    }
//
//    char *msgBytes = NULL;
//    size_t msgBytesSze = 0;
//    PEP_STATUS status1 = encode_ASN1Message_message(asn1Message1, &msgBytes, &msgBytesSze);
//
//    if (status1 != PEP_STATUS_OK) {
//        return NO;
//    }
//
//    if (msgBytes == NULL) {
//        return NO;
//    }
//
//    if (msgBytesSze == 0) {
//        return NO;
//    }
//
//    // decode
//
//    ASN1Message_t *asn1Message2 = NULL;
//    PEP_STATUS status2 = decode_ASN1Message_message(msgBytes, msgBytesSze, &asn1Message2);
//    if (status2 != PEP_STATUS_OK) {
//        return NO;
//    }
//
//    message *msg2 = ASN1Message_to_message(asn1Message2, NULL, YES, 0);
//    if (!msg2) {
//        return NO;
//    }
//
//    if (strcmp(msg1->longmsg, msg2->longmsg) != 0) {
//        return NO;
//    }
//
//    if (msg2->attachments == NULL) {
//        return NO;
//    }
//
//    if (msg2->attachments->value == NULL) {
//        return NO;
//    }
//
//    if (msg1->attachments->size != msg2->attachments->size) {
//        return NO;
//    }
//
//    if (strncmp(msg1->attachments->value, msg2->attachments->value, msg1->attachments->size)) {
//        return NO;
//    }
//
//    // traverse the attachment data, which should lead to a heap-buffer-overflow
//    char *bytesToTraverse = msg2->attachments->value;
//    for (size_t i = 0; i < msg2->attachments->size; ++i) {
//        char byte = bytesToTraverse[i];
//        byte = 0; // eliminate compiler warning
//    }
//
//    // free
//
//    free_message(msg1);
//    free_message(msg2);
//
//    return YES;
//}
