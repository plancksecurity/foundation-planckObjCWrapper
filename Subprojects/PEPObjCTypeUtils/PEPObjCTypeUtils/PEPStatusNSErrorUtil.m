//
//  NSErrorPEPStatusUtil.m
//  PEPObjCTypeUtils
//
//  Created by Andreas Buff on 15.11.21.
//

#import "PEPStatusNSErrorUtil.h"

#import <PEPObjCTypes.h>
#import <pEpEngine.h>
#import <status_to_string.h>

@implementation PEPStatusNSErrorUtil

+ (NSError * _Nullable)errorWithPEPStatus:(PEPStatus)status
{
    return [self errorWithPEPStatusInternal:(PEP_STATUS)status];
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

// MARK: - PRIVATE

// MARK: - NSString From PEP_STATUS

/// Could in theory return a fully localized version of the underlying error.
+ (NSString * _Nonnull)localizedErrorStringFromPEPStatus:(PEP_STATUS) status {
    return [self stringFromPEPStatus:status];
}

+ (NSString * _Nonnull)stringFromPEPStatus:(PEP_STATUS)status {
    const char *pstrStatus = pEp_status_to_string(status);
    return [NSString stringWithUTF8String:pstrStatus];
}

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
        case PEP_CANNOT_REENCRYPT:
            return nil;
            break;

        default: {
            NSDictionary *dict = [NSDictionary
                                  dictionaryWithObjectsAndKeys:[self localizedErrorStringFromPEPStatus:status],
                                  NSLocalizedDescriptionKey, nil];
            return [NSError
                    errorWithDomain:PEPObjCEngineStatusErrorDomain
                    code:status
                    userInfo:dict];
        }
            break;
    }
}

@end
