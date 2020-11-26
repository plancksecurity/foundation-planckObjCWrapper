//
//  PEPTypes.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 27.02.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#ifndef PEPTypes_h
#define PEPTypes_h

#import <Foundation/Foundation.h>

typedef NS_CLOSED_ENUM(int, PEPStatus) {
    PEPStatusOK = 0, // PEP_STATUS_OK

    PEPStatusInitCannotLoadGPME = 0x0110, // PEP_INIT_CANNOT_LOAD_GPGME
    PEPStatusInitGPGMEInitFailed = 0x0111, // PEP_INIT_GPGME_INIT_FAILED
    PEPStatusInitNoGPGHome = 0x0112, // PEP_INIT_NO_GPG_HOME
    PEPStatusInitNETPGPInitFailed = 0x0113, // PEP_INIT_NETPGP_INIT_FAILED
    PEPStatusInitCannotDetermineGPGVersion = 0x0114, // PEP_INIT_CANNOT_DETERMINE_GPG_VERSION
    PEPStatusInitUnsupportedGPGVersion = 0x0115, // PEP_INIT_UNSUPPORTED_GPG_VERSION
    PEPStatusInitCannotConfigGPGAgent = 0x0116, // PEP_INIT_CANNOT_CONFIG_GPG_AGENT

    PEPStatusInitSqlite3WithoutMutex = 0x0120, // PEP_INIT_SQLITE3_WITHOUT_MUTEX
    PEPStatusInitCannotOpenDB = 0x0121, // PEP_INIT_CANNOT_OPEN_DB
    PEPStatusInitCannotOpenSystemDB = 0x0122, // PEP_INIT_CANNOT_OPEN_SYSTEM_DB
    PEPStatusUnknownDBError = 0x01ff, // PEP_UNKNOWN_DB_ERROR

    PEPStatusKeyNotFound = 0x0201, // PEP_KEY_NOT_FOUND
    PEPStatusKeyHasAmbigName = 0x0202, // PEP_KEY_HAS_AMBIG_NAME
    PEPStatusGetKeyFailed = 0x0203, // PEP_GET_KEY_FAILED
    PEPStatusCannotExportKey = 0x0204, // PEP_CANNOT_EXPORT_KEY
    PEPStatusCannotEditKey = 0x0205, // PEP_CANNOT_EDIT_KEY
    PEPStatusKeyUnsuitable = 0x0206, // PEP_KEY_UNSUITABLE
    PEPStatusMalformedKeyResetMsg = 0x0210, // PEP_MALFORMED_KEY_RESET_MSG
    PEPStatusKeyNotReset = 0x0211, // PEP_KEY_NOT_RESET
    PEPStatusCannotDeleteKey = 0x0212, // PEP_CANNOT_DELETE_KEY

    PEPStatusKeyImported = 0x0220, // PEP_KEY_IMPORTED
    PEPStatusNoKeyImported = 0x0221, // PEP_NO_KEY_IMPORTED
    PEPStatusKeyImportStatusUnknown = 0x0222, // PEP_KEY_IMPORT_STATUS_UNKNOWN
    PEPStatusSomeKeysImported = 0x0223, // PEP_SOME_KEYS_IMPORTED

    PEPStatusCannotFindIdentity = 0x0301, // PEP_CANNOT_FIND_IDENTITY
    PEPStatusCannotSetPerson = 0x0381, // PEP_CANNOT_SET_PERSON
    PEPStatusCannotSetPGPKeyPair = 0x0382, // PEP_CANNOT_SET_PGP_KEYPAIR
    PEPStatusCannotSetIdentity = 0x0383, // PEP_CANNOT_SET_IDENTITY
    PEPStatusCannotSetTrust = 0x0384, // PEP_CANNOT_SET_TRUST
    PEPStatusKeyBlacklisted = 0x0385, // PEP_KEY_BLACKLISTED
    PEPStatusCannotFindPerson = 0x0386, // PEP_CANNOT_FIND_PERSON
    PEPStatusCannotSetPEPVersion = 0X0387, // PEP_CANNOT_SET_PEP_VERSION

    PEPStatusCannotFindAlias = 0x0391, // PEP_CANNOT_FIND_ALIAS
    PEPStatusCannotSetAlias = 0x0392, // PEP_CANNOT_SET_ALIAS

    PEPStatusUnencrypted = 0x0400, // PEP_UNENCRYPTED
    PEPStatusVerified = 0x0401, // PEP_VERIFIED
    PEPStatusDecrypted = 0x0402, // PEP_DECRYPTED
    PEPStatusDecryptedAndVerified = 0x0403, // PEP_DECRYPTED_AND_VERIFIED
    PEPStatusDecryptWrongFormat = 0x0404, // PEP_DECRYPT_WRONG_FORMAT
    PEPStatusDecryptNoKey = 0x0405, // PEP_DECRYPT_NO_KEY
    PEPStatusDecryptSignatureDoesNotMatch = 0x0406, // PEP_DECRYPT_SIGNATURE_DOES_NOT_MATCH
    PEPStatusVerifyNoKey = 0x0407, // PEP_VERIFY_NO_KEY
    PEPStatusVerifiedAndTrusted = 0x0408, // PEP_VERIFIED_AND_TRUSTED
    PEPStatusCannotReencrypt = 0x0409, // PEP_CANNOT_REENCRYPT
    PEPStatusVerifySignerKeyRevoked = 0x040a, // PEP_VERIFY_SIGNER_KEY_REVOKED
    PEPStatusCannotDecryptUnknown = 0x04ff, // PEP_CANNOT_DECRYPT_UNKNOWN

    PEPStatusTrustwordNotFound = 0x0501, // PEP_TRUSTWORD_NOT_FOUND
    PEPStatusTrustwordsFPRWrongLength = 0x0502, // PEP_TRUSTWORDS_FPR_WRONG_LENGTH
    PEPStatusTrustwordsDuplicateFPR = 0x0503, // PEP_TRUSTWORDS_DUPLICATE_FPR

    PEPStatusCannotCreateKey = 0x0601, // PEP_CANNOT_CREATE_KEY
    PEPStatusCannotSendKey = 0x0602, // PEP_CANNOT_SEND_KEY

    PEPStatusPhraseNotFound = 0x0701, // PEP_PHRASE_NOT_FOUND

    PEPStatusSendFunctionNotRegistered = 0x0801, // PEP_SEND_FUNCTION_NOT_REGISTERED
    PEPStatusConstraintsViolated = 0x0802, // PEP_CONTRAINTS_VIOLATED
    PEPStatusCannotEncode = 0x0803, // PEP_CANNOT_ENCODE

    PEPStatusSyncNoNotifyCallback = 0x0901, // PEP_SYNC_NO_NOTIFY_CALLBACK
    PEPStatusSyncIllegalMessage = 0x0902, // PEP_SYNC_ILLEGAL_MESSAGE
    PEPStatusSyncNoInjectCallback = 0x0903, // PEP_SYNC_NO_INJECT_CALLBACK
    PEPStatusSyncNoChannel = 0x0904, // PEP_SYNC_NO_CHANNEL
    PEPStatusSyncCannotEncrypt = 0x0905, // PEP_SYNC_CANNOT_ENCRYPT
    PEPStatusSyncNoMessageSendCallback = 0x0906, // PEP_SYNC_NO_MESSAGE_SEND_CALLBACK
    PEPStatusSyncCannotStart = 0x0907, // PEP_SYNC_CANNOT_START

    PEPStatusCannotIncreaseSequence = 0x0971, // PEP_CANNOT_INCREASE_SEQUENCE

    PEPStatusStatemachineError = 0x0980, // PEP_STATEMACHINE_ERROR
    PEPStatusNoTrust = 0x0981, // PEP_NO_TRUST
    PEPStatusStatemachineInvalidState = 0x0982, // PEP_STATEMACHINE_INVALID_STATE
    PEPStatusStatemachineInvalidEvent = 0x0983, // PEP_STATEMACHINE_INVALID_EVENT
    PEPStatusStatemachineInvalidCondition = 0x0984, // PEP_STATEMACHINE_INVALID_CONDITION
    PEPStatusStatemachineInvalidAction = 0x0985, // PEP_STATEMACHINE_INVALID_ACTION
    PEPStatusStatemachineInhibitedEvent = 0x0986, // PEP_STATEMACHINE_INHIBITED_EVENT
    PEPStatusStatemachineCannotSend = 0x0987, // PEP_STATEMACHINE_CANNOT_SEND

    PEPStatusPassphraseRequired = 0x0a00, // PEP_PASSPHRASE_REQUIRED
    PEPStatusWrongPassphrase = 0x0a01, // PEP_WRONG_PASSPHRASE
    PEPStatusPassphraseForNewKeysRequired = 0x0a02, // PEP_PASSPHRASE_FOR_NEW_KEYS_REQUIRED

    PEPStatusDistributionIllegalMessage = 0x1002, // PEP_DISTRIBUTION_ILLEGAL_MESSAGE,

    PEPStatusCommitFailed = 0xff01, // PEP_COMMIT_FAILED
    PEPStatusMessageConsume = 0xff02, // PEP_MESSAGE_CONSUME
    PEPStatusMessageIgnore = 0xff03, // PEP_MESSAGE_IGNORE
    PEPStatusCannotConfig = 0xff04, // PEP_CANNOT_CONFIG

    PEPStatusRecordNotFound = -6, // PEP_RECORD_NOT_FOUND
    PEPStatusCannotCreateTempFile = -5, // PEP_CANNOT_CREATE_TEMP_FILE
    PEPStatusIllegalValue = -4, // PEP_ILLEGAL_VALUE
    PEPStatusBufferTooSmall = -3, // PEP_BUFFER_TOO_SMALL
    PEPStatusOutOfMemory = -2, // PEP_OUT_OF_MEMORY
    PEPStatusUnknownError = -1, // PEP_UNKNOWN_ERROR

    PEPStatusVersionMismatch = -7, // PEP_VERSION_MISMATCH
};

typedef NS_CLOSED_ENUM(int, PEPIdentityFlags) {
    PEPIdentityFlagsNotForSync = 0x0001, // PEP_idf_not_for_sync
    PEPIdentityFlagsList = 0x0002, // PEP_idf_list = 0x0002
    PEPIdentityFlagsDeviceGroup = 0x0100 // PEP_idf_devicegroup
};

typedef NS_CLOSED_ENUM(int, PEPSyncHandshakeSignal) {
    PEPSyncHandshakeSignalUndefined = 0, // SYNC_NOTIFY_UNDEFINED

    PEPSyncHandshakeSignalInitAddOurDevice = 1, // SYNC_NOTIFY_INIT_ADD_OUR_DEVICE
    PEPSyncHandshakeSignalInitAddOtherDevice = 2, // SYNC_NOTIFY_INIT_ADD_OTHER_DEVICE
    PEPSyncHandshakeSignalInitFormGroup = 3, // SYNC_NOTIFY_INIT_FORM_GROUP

    PEPSyncHandshakeSignalTimeout = 5, // SYNC_NOTIFY_TIMEOUT

    PEPSyncHandshakeSignalAcceptedDeviceAdded = 6, // SYNC_NOTIFY_ACCEPTED_DEVICE_ADDED
    PEPSyncHandshakeSignalAcceptedGroupCreated = 7, // SYNC_NOTIFY_ACCEPTED_GROUP_CREATED

    PEPSyncHandshakeSignalAcceptedDeviceAccepted = 8, // SYNC_NOTIFY_ACCEPTED_DEVICE_ACCEPTED

    PEPSyncHandshakeSignalStop = 127, // SYNC_NOTIFY_STOP

    PEPSyncHandshakeSignalPassphraseRequired = 128, // SYNC_PASSPHRASE_REQUIRED

    PEPSyncHandshakeSignalSole = 254, // SYNC_NOTIFY_SOLE
    PEPSyncHandshakeSignalInGroup = 255 // SYNC_NOTIFY_IN_GROUP
};

#endif /* PEPTypes_h */