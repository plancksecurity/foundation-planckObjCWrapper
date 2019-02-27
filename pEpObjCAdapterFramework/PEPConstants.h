//
//  PEPConstants.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 27.02.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#ifndef PEPConstants_h
#define PEPConstants_h

typedef enum _ObjC_PEP_decrypt_flags {
    PEPDecryptFlagOwnPrivateKey = 0x1, // PEP_decrypt_flag_own_private_key = 0x1,
    PEPDecryptFlagConsume = 0x2, // PEP_decrypt_flag_consume = 0x2,
    PEPDecryptFlagIgnore = 0x4, // PEP_decrypt_flag_ignore = 0x4,
    PEPDecryptFlagSrcModified = 0x8, // PEP_decrypt_flag_src_modified = 0x8,
    // input flags
    PEPDecryptFlagUntrustedServer = 0x100 // PEP_decrypt_flag_untrusted_server = 0x100
} PEPDecryptFlags; // PEP_decrypt_flags;

typedef enum _ObjC_PEP_enc_format {
    PEPEncNone = 0, // PEP_enc_none = 0, // message is not encrypted
    PEPEncPieces, // PEP_enc_pieces, // inline PGP + PGP extensions
    PEPEncSMIME, // PEP_enc_S_MIME, // RFC5751
    PEPEncPGPMIME, // PEP_enc_PGP_MIME, // RFC3156
    PEPEncPEP, // PEP_enc_PEP, // pEp encryption format
    PEPEncPGPMIMEOutlook1 // PEP_enc_PGP_MIME_Outlook1 // Message B0rken by Outlook type 1
} PEPEncFormat;

typedef enum _ObjC_PEP_rating {
    PEPRatingUndefined = 0,// PEP_rating_undefined = 0,
    PEPRatingCannotDecrypt, // PEP_rating_cannot_decrypt,
    PEPRatingHaveNoKey, // PEP_rating_have_no_key,
    PEPRatingUnencrypted, // PEP_rating_unencrypted,
    PEPRatingUnencryptedForSome, // PEP_rating_unencrypted_for_some, // don't use this any more
    PEPRatingUnreliable, // PEP_rating_unreliable,
    PEPRatingReliable, // PEP_rating_reliable,
    PEPRatingTrusted, // PEP_rating_trusted,
    PEPRatingTrustedAndAnonymized, // PEP_rating_trusted_and_anonymized,
    PEPRatingFullyAnonymous, // PEP_rating_fully_anonymous,

    PEPRatingMistrust = -1, // PEP_rating_mistrust = -1,
    PEPRatingB0rken = -2, // PEP_rating_b0rken = -2,
    PEPRatingUnderAttack = -3 // PEP_rating_under_attack = -3
} PEPRating;

typedef enum {
    PEPStatusOK                                   = 0, // PEP_STATUS_OK

    PEPInitCannotLoadGPME                      = 0x0110, // PEP_INIT_CANNOT_LOAD_GPGME
    PEPInitGPGMEInitFailed                      = 0x0111, // PEP_INIT_GPGME_INIT_FAILED
    PEPInitNoGPGHome                            = 0x0112, // PEP_INIT_NO_GPG_HOME
    PEPInitNETPGPInitFailed                     = 0x0113, // PEP_INIT_NETPGP_INIT_FAILED
    PEPInitCannotDetermineGPGVersion           = 0x0114, // PEP_INIT_CANNOT_DETERMINE_GPG_VERSION
    PEPInitUnsupportedGPGVersion                = 0x0115, // PEP_INIT_UNSUPPORTED_GPG_VERSION
    PEPInitCannotConfigGPGAgent                = 0x0116, // PEP_INIT_CANNOT_CONFIG_GPG_AGENT

    PEPInitSqlite3WithoutMutex                  = 0x0120, // PEP_INIT_SQLITE3_WITHOUT_MUTEX
    PEPInitCannotOpenDB                         = 0x0121, // PEP_INIT_CANNOT_OPEN_DB
    PEPInitCannotOpenSystemDB                  = 0x0122, // PEP_INIT_CANNOT_OPEN_SYSTEM_DB
    PEPUnknownDBError                            = 0x01ff, // PEP_UNKNOWN_DB_ERROR

    PEPKeyNotFound                               = 0x0201, // PEP_KEY_NOT_FOUND
    PEPKeyHasAmbigName                          = 0x0202, // PEP_KEY_HAS_AMBIG_NAME
    PEPGetKeyFailed                              = 0x0203, // PEP_GET_KEY_FAILED
    PEPCannotExportKey                           = 0x0204, // PEP_CANNOT_EXPORT_KEY
    PEPCannotEditKey                             = 0x0205, // PEP_CANNOT_EDIT_KEY
    PEPKeyUnsuitable                              = 0x0206, // PEP_KEY_UNSUITABLE
    PEPMalformedKeyResetMsg                     = 0x0210, // PEP_MALFORMED_KEY_RESET_MSG
    PEPKeyNotReset                               = 0x0211, // PEP_KEY_NOT_RESET

    PEPKeyImported                                = 0x0220, // PEP_KEY_IMPORTED
    PEPNoKeyImported                             = 0x0221, // PEP_NO_KEY_IMPORTED
    PEPKeyImportStatusUnknown                   = 0x0222, // PEP_KEY_IMPORT_STATUS_UNKNOWN

    PEPCannotFindIdentity                        = 0x0301, // PEP_CANNOT_FIND_IDENTITY
    PEPCannotSetPerson                           = 0x0381, // PEP_CANNOT_SET_PERSON
    PEPCannotSetPGPKeyPair                      = 0x0382, // PEP_CANNOT_SET_PGP_KEYPAIR
    PEPCannotSetIdentity                         = 0x0383, // PEP_CANNOT_SET_IDENTITY
    PEPCannotSetTrust                            = 0x0384, // PEP_CANNOT_SET_TRUST
    PEPKeyBlacklisted                             = 0x0385, // PEP_KEY_BLACKLISTED
    PEPCannotFindPerson                          = 0x0386, // PEP_CANNOT_FIND_PERSON

    PEPCannotFindAlias                           = 0x0391, // PEP_CANNOT_FIND_ALIAS
    PEPCannotSetAlias                            = 0x0392, // PEP_CANNOT_SET_ALIAS

    PEPUnencrypted                                 = 0x0400, // PEP_UNENCRYPTED
    PEPVerified                                    = 0x0401, // PEP_VERIFIED
    PEPDecrypted                                   = 0x0402, // PEP_DECRYPTED
    PEPDecryptedAndVerified                      = 0x0403, // PEP_DECRYPTED_AND_VERIFIED
    PEPDecryptWrongFormat                        = 0x0404, // PEP_DECRYPT_WRONG_FORMAT
    PEPDecryptNoKey                              = 0x0405, // PEP_DECRYPT_NO_KEY
    PEPDecryptSignatureDoesNotMatch            = 0x0406, // PEP_DECRYPT_SIGNATURE_DOES_NOT_MATCH
    PEPVerifyNoKey                               = 0x0407, // PEP_VERIFY_NO_KEY
    PEPVerifiedAndTrusted                        = 0x0408, // PEP_VERIFIED_AND_TRUSTED
    PEPCannotReencrypt                            = 0x0409, // PEP_CANNOT_REENCRYPT
    PEPCannotDecryptUnknown                      = 0x04ff, // PEP_CANNOT_DECRYPT_UNKNOWN

    PEPTrustwordNotFound                         = 0x0501, // PEP_TRUSTWORD_NOT_FOUND
    PEPTrustwordsFPRWrongLength                 = 0x0502, // PEP_TRUSTWORDS_FPR_WRONG_LENGTH
    PEPTrustwordsDuplicateFPR                    = 0x0503, // PEP_TRUSTWORDS_DUPLICATE_FPR

    PEPCannotCreateKey                           = 0x0601, // PEP_CANNOT_CREATE_KEY
    PEPCannotSendKey                             = 0x0602, // PEP_CANNOT_SEND_KEY

    PEPPhraseNotFound                            = 0x0701, // PEP_PHRASE_NOT_FOUND

    PEPSendFunctionNotRegistered                = 0x0801, // PEP_SEND_FUNCTION_NOT_REGISTERED
    PEPConstraintsViolated                         = 0x0802, // PEP_CONTRAINTS_VIOLATED
    PEPCannotEncode                               = 0x0803, // PEP_CANNOT_ENCODE

    PEPSyncNoNotifyCallback                     = 0x0901, // PEP_SYNC_NO_NOTIFY_CALLBACK
    PEPSyncIllegalMessage                        = 0x0902, // PEP_SYNC_ILLEGAL_MESSAGE
    PEPSyncNoInjectCallback                     = 0x0903, // PEP_SYNC_NO_INJECT_CALLBACK
    PEPSyncNoChannel                             = 0x0904, // PEP_SYNC_NO_CHANNEL
    PEPSyncCannotEncrypt                         = 0x0905, // PEP_SYNC_CANNOT_ENCRYPT
    PEPSyncNoMessageSendCallback               = 0x0906, // PEP_SYNC_NO_MESSAGE_SEND_CALLBACK

    PEPCannotIncreaseSequence                    = 0x0971, // PEP_CANNOT_INCREASE_SEQUENCE

    PEPStatemachineError                          = 0x0980, // PEP_STATEMACHINE_ERROR
    PEPNoTrust                                    = 0x0981, // PEP_NO_TRUST
    PEPStatemachineInvalidState                  = 0x0982, // PEP_STATEMACHINE_INVALID_STATE
    PEPStatemachineInvalidEvent                  = 0x0983, // PEP_STATEMACHINE_INVALID_EVENT
    PEPStatemachineInvalidCondition              = 0x0984, // PEP_STATEMACHINE_INVALID_CONDITION
    PEPStatemachineInvalidAction                 = 0x0985, // PEP_STATEMACHINE_INVALID_ACTION
    PEPStatemachineInhibitedEvent                = 0x0986, // PEP_STATEMACHINE_INHIBITED_EVENT
    PEPStatemachineCannotSend                    = 0x0987, // PEP_STATEMACHINE_CANNOT_SEND

    PEPCommitFailed                               = 0xff01, // PEP_COMMIT_FAILED
    PEPMessageConsume                             = 0xff02, // PEP_MESSAGE_CONSUME
    PEPMessageIgnore                              = 0xff03, // PEP_MESSAGE_IGNORE

    PEPRecordNotFound                            = -6, // PEP_RECORD_NOT_FOUND
    PEPCannotCreateTempFile                     = -5, // PEP_CANNOT_CREATE_TEMP_FILE
    PEPIllegalValue                               = -4, // PEP_ILLEGAL_VALUE
    PEPBufferTooSmall                            = -3, // PEP_BUFFER_TOO_SMALL
    PEPOutOfMemory                               = -2, // PEP_OUT_OF_MEMORY
    PEPUnknownError                               = -1, // PEP_UNKNOWN_ERROR

    PEPVersionMismatch                            = -7, // PEP_VERSION_MISMATCH
} PEPStatus;

typedef enum _ObjC_identity_flags {
    // the first octet flags are app defined settings
    PEPIdfNotForSync = 0x0001, // PEP_idf_not_for_sync = 0x0001,   // don't use this identity for sync
    PEPIdfList = 0x0002, // PEP_idf_list = 0x0002,           // identity of list of persons
    // the second octet flags are calculated
    PEPIdfDeviceGroup = 0x0100 // PEP_idf_devicegroup = 0x0100     // identity of a device group member
} PEPIdentityFlags;

#endif /* PEPConstants_h */
