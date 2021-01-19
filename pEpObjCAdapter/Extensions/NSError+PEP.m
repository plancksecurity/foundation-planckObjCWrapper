//
//  NSError+PEP.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 20.02.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPTypes.h"

#import "NSError+PEP.h"
#import "NSError+PEP+Internal.h"

#import "status_to_string.h"

#import "PEPSessionProtocol.h"

@implementation NSError (Extension)

+ (NSError * _Nullable)errorWithPEPStatusInternal:(PEP_STATUS)status
{
    switch (status) {
        case PEP_STATUS_OK:
        case PEP_DECRYPTED:
        case PEP_UNENCRYPTED:
        case PEP_DECRYPT_NO_KEY:
        case PEP_KEY_IMPORTED:
        case PEP_KEY_IMPORT_STATUS_UNKNOWN:
        case PEP_VERIFY_SIGNER_KEY_REVOKED:
        case PEP_DECRYPT_SIGNATURE_DOES_NOT_MATCH:
            return nil;
            break;

        default: {
            NSDictionary *dict = [NSDictionary
                                  dictionaryWithObjectsAndKeys:localizedErrorStringFromPEPStatus(status),
                                  NSLocalizedDescriptionKey, nil];
            return [NSError
                    errorWithDomain:PEPObjCAdapterEngineStatusErrorDomain
                    code:status
                    userInfo:dict];
        }
            break;
    }
}

+ (NSError * _Nullable)errorWithPEPStatus:(PEPStatus)status
{
    return [self errorWithPEPStatusInternal:(PEP_STATUS) status];
}

+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromPEPStatus:(PEPStatus)status
{
    // Determine if the given status is an error.
    NSError *errorFromStatus = [self errorWithPEPStatus:status];

    // Set caller's error, if given
    if (error) {
        *error = errorFromStatus;
    }

    // Indicate error status.
    if (errorFromStatus) {
        return YES;
    } else {
        return NO;
    }
}

/**
 Could in theory return a fully localized version of the underlying error.
 */
NSString * _Nonnull localizedErrorStringFromPEPStatus(PEP_STATUS status) {
    return stringFromPEPStatus(status);
}

NSString * _Nonnull stringFromPEPStatus(PEP_STATUS status) {
    const char *pstrStatus = pEp_status_to_string(status);
    return [NSString stringWithUTF8String:pstrStatus];
}

- (NSString * _Nullable)pEpErrorString
{
    if ([self.domain isEqualToString:PEPObjCAdapterEngineStatusErrorDomain]) {
        return stringFromPEPStatus((PEP_STATUS) self.code);
    } else {
        return nil;
    }
}

@end
