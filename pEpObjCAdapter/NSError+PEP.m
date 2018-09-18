//
//  NSError+PEP.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 20.02.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "NSError+PEP.h"

static NSString *s_pEpAdapterDomain = @"security.pEp.ObjCAdapter";

@implementation NSError (Extension)

+ (NSError * _Nonnull)errorWithPEPStatus:(PEP_STATUS)status
                                userInfo:(NSDictionary<NSErrorUserInfoKey, id> * _Nonnull)dict
{
    switch (status) {
        case PEP_STATUS_OK:
        case PEP_DECRYPTED:
        case PEP_UNENCRYPTED:
        case PEP_DECRYPT_NO_KEY:
            return nil;
            break;

        default:
            if (![dict objectForKey:NSLocalizedDescriptionKey]) {
                NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithDictionary:dict];
                [dict2 setValue:localizedErrorStringFromPEPStatus(status)
                         forKey:NSLocalizedDescriptionKey];
                dict = dict2;
            }
            return [NSError errorWithDomain:s_pEpAdapterDomain code:status userInfo:dict];
            break;
    }
}

+ (NSError * _Nonnull)errorWithPEPStatus:(PEP_STATUS)status
{
    NSDictionary *userInfo = [NSDictionary new];
    return [self errorWithPEPStatus:status userInfo:userInfo];
}

+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromPEPStatus:(PEP_STATUS)status
{
    NSError *theError = [self errorWithPEPStatus:status];
    if (theError) {
        if (error) {
            *error = theError;
        }
        return YES;
    } else {
        if (error) {
            *error = nil;
        }
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
    switch (status) {
        case PEP_STATUS_OK: return @"PEP_STATUS_OK";
        case PEP_INIT_CANNOT_LOAD_GPGME: return @"PEP_INIT_CANNOT_LOAD_GPGME";
        case PEP_INIT_GPGME_INIT_FAILED: return @"PEP_INIT_GPGME_INIT_FAILED";
        case PEP_INIT_NO_GPG_HOME: return @"PEP_INIT_NO_GPG_HOME";
        case PEP_INIT_NETPGP_INIT_FAILED: return @"PEP_INIT_NETPGP_INIT_FAILED";
        case PEP_INIT_CANNOT_DETERMINE_GPG_VERSION: return @"PEP_INIT_CANNOT_DETERMINE_GPG_VERSION";
        case PEP_INIT_UNSUPPORTED_GPG_VERSION: return @"PEP_INIT_UNSUPPORTED_GPG_VERSION";
        case PEP_INIT_CANNOT_CONFIG_GPG_AGENT: return @"PEP_INIT_CANNOT_CONFIG_GPG_AGENT";
        case PEP_INIT_SQLITE3_WITHOUT_MUTEX: return @"PEP_INIT_SQLITE3_WITHOUT_MUTEX";
        case PEP_INIT_CANNOT_OPEN_DB: return @"PEP_INIT_CANNOT_OPEN_DB";
        case PEP_INIT_CANNOT_OPEN_SYSTEM_DB: return @"PEP_INIT_CANNOT_OPEN_SYSTEM_DB";
        case PEP_KEY_NOT_FOUND: return @"PEP_KEY_NOT_FOUND";
        case PEP_KEY_HAS_AMBIG_NAME: return @"PEP_KEY_HAS_AMBIG_NAME";
        case PEP_GET_KEY_FAILED: return @"PEP_GET_KEY_FAILED";
        case PEP_CANNOT_EXPORT_KEY: return @"PEP_CANNOT_EXPORT_KEY";
        case PEP_CANNOT_EDIT_KEY: return @"PEP_CANNOT_EDIT_KEY";
        case PEP_KEY_UNSUITABLE: return @"PEP_KEY_UNSUITABLE";
        case PEP_CANNOT_FIND_IDENTITY: return @"PEP_CANNOT_FIND_IDENTITY";
        case PEP_CANNOT_SET_PERSON: return @"PEP_CANNOT_SET_PERSON";
        case PEP_CANNOT_SET_PGP_KEYPAIR: return @"PEP_CANNOT_SET_PGP_KEYPAIR";
        case PEP_CANNOT_SET_IDENTITY: return @"PEP_CANNOT_SET_IDENTITY";
        case PEP_CANNOT_SET_TRUST: return @"PEP_CANNOT_SET_TRUST";
        case PEP_KEY_BLACKLISTED: return @"PEP_KEY_BLACKLISTED";
        case PEP_CANNOT_FIND_PERSON: return @"PEP_CANNOT_FIND_PERSON";
        case PEP_CANNOT_FIND_ALIAS: return @"PEP_CANNOT_FIND_ALIAS";
        case PEP_CANNOT_SET_ALIAS: return @"PEP_CANNOT_SET_ALIAS";
        case PEP_UNENCRYPTED: return @"PEP_UNENCRYPTED";
        case PEP_VERIFIED: return @"PEP_VERIFIED";
        case PEP_DECRYPTED: return @"PEP_DECRYPTED";
        case PEP_DECRYPTED_AND_VERIFIED: return @"PEP_DECRYPTED_AND_VERIFIED";
        case PEP_DECRYPT_WRONG_FORMAT: return @"PEP_DECRYPT_WRONG_FORMAT";
        case PEP_DECRYPT_NO_KEY: return @"PEP_DECRYPT_NO_KEY";
        case PEP_DECRYPT_SIGNATURE_DOES_NOT_MATCH: return @"PEP_DECRYPT_SIGNATURE_DOES_NOT_MATCH";
        case PEP_VERIFY_NO_KEY: return @"PEP_VERIFY_NO_KEY";
        case PEP_VERIFIED_AND_TRUSTED: return @"PEP_VERIFIED_AND_TRUSTED";
        case PEP_CANNOT_DECRYPT_UNKNOWN: return @"PEP_CANNOT_DECRYPT_UNKNOWN";
        case PEP_TRUSTWORD_NOT_FOUND: return @"PEP_TRUSTWORD_NOT_FOUND";
        case PEP_TRUSTWORDS_FPR_WRONG_LENGTH: return @"PEP_TRUSTWORDS_FPR_WRONG_LENGTH";
        case PEP_TRUSTWORDS_DUPLICATE_FPR: return @"PEP_TRUSTWORDS_DUPLICATE_FPR";
        case PEP_CANNOT_CREATE_KEY: return @"PEP_CANNOT_CREATE_KEY";
        case PEP_CANNOT_SEND_KEY: return @"PEP_CANNOT_SEND_KEY";
        case PEP_PHRASE_NOT_FOUND: return @"PEP_PHRASE_NOT_FOUND";
        case PEP_SEND_FUNCTION_NOT_REGISTERED: return @"PEP_SEND_FUNCTION_NOT_REGISTERED";
        case PEP_CONTRAINTS_VIOLATED: return @"PEP_CONTRAINTS_VIOLATED";
        case PEP_CANNOT_ENCODE: return @"PEP_CANNOT_ENCODE";
        case PEP_SYNC_NO_NOTIFY_CALLBACK: return @"PEP_SYNC_NO_NOTIFY_CALLBACK";
        case PEP_SYNC_ILLEGAL_MESSAGE: return @"PEP_SYNC_ILLEGAL_MESSAGE";
        case PEP_SYNC_NO_INJECT_CALLBACK: return @"PEP_SYNC_NO_INJECT_CALLBACK";
        case PEP_SEQUENCE_VIOLATED: return @"PEP_SEQUENCE_VIOLATED";
        case PEP_CANNOT_INCREASE_SEQUENCE: return @"PEP_CANNOT_INCREASE_SEQUENCE";
        case PEP_CANNOT_SET_SEQUENCE_VALUE: return @"PEP_CANNOT_SET_SEQUENCE_VALUE";
        case PEP_OWN_SEQUENCE: return @"PEP_OWN_SEQUENCE";
        case PEP_SYNC_STATEMACHINE_ERROR: return @"PEP_SYNC_STATEMACHINE_ERROR";
        case PEP_SYNC_NO_TRUST: return @"PEP_SYNC_NO_TRUST";
        case PEP_STATEMACHINE_INVALID_STATE: return @"PEP_STATEMACHINE_INVALID_STATE";
        case PEP_STATEMACHINE_INVALID_EVENT: return @"PEP_STATEMACHINE_INVALID_EVENT";
        case PEP_STATEMACHINE_INVALID_CONDITION: return @"PEP_STATEMACHINE_INVALID_CONDITION";
        case PEP_STATEMACHINE_INVALID_ACTION: return @"PEP_STATEMACHINE_INVALID_ACTION";
        case PEP_STATEMACHINE_INHIBITED_EVENT: return @"PEP_STATEMACHINE_INHIBITED_EVENT";
        case PEP_COMMIT_FAILED: return @"PEP_COMMIT_FAILED";
        case PEP_MESSAGE_CONSUME: return @"PEP_MESSAGE_CONSUME";
        case PEP_MESSAGE_IGNORE: return @"PEP_MESSAGE_IGNORE";
        case PEP_RECORD_NOT_FOUND: return @"PEP_RECORD_NOT_FOUND";
        case PEP_CANNOT_CREATE_TEMP_FILE: return @"PEP_CANNOT_CREATE_TEMP_FILE";
        case PEP_ILLEGAL_VALUE: return @"PEP_ILLEGAL_VALUE";
        case PEP_BUFFER_TOO_SMALL: return @"PEP_BUFFER_TOO_SMALL";
        case PEP_OUT_OF_MEMORY: return @"PEP_OUT_OF_MEMORY";
        case PEP_UNKNOWN_ERROR: return @"PEP_UNKNOWN_ERROR";
        case PEP_VERSION_MISMATCH: return @"PEP_VERSION_MISMATCH";
        case PEP_CANNOT_REENCRYPT: return @"PEP_CANNOT_REENCRYPT";
        case PEP_UNKNOWN_DB_ERROR: return @"PEP_UNKNOWN_DB_ERROR";
        case PEP_MALFORMED_KEY_RESET_MSG: return @"PEP_MALFORMED_KEY_RESET_MSG";
        case PEP_KEY_NOT_RESET: return @"PEP_KEY_NOT_RESET";
        case PEP_SYNC_INJECT_FAILED: return @"PEP_SYNC_INJECT_FAILED";
        case PEP_SYNC_NO_MESSAGE_SEND_CALLBACK: return @"PEP_SYNC_NO_MESSAGE_SEND_CALLBACK";
    }
}

- (NSString * _Nullable)pEpErrorString
{
    if ([self.domain isEqualToString:s_pEpAdapterDomain]) {
        return stringFromPEPStatus((PEP_STATUS) self.code);
    } else {
        return nil;
    }
}

@end
