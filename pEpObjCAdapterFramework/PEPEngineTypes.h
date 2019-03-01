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

typedef enum _ObjC_PEP_decrypt_flags {
    PEPDecryptFlagNone = 0x1, // This defined only in the adpater, not the engine.
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

typedef enum _ObjC_sync_handshake_result {
    PEPSyncHandshakeResultCancel = -1, // SYNC_HANDSHAKE_CANCEL = -1,
    PEPSyncHandshakeResultAccepted = 0, // SYNC_HANDSHAKE_ACCEPTED = 0,
    PEPSyncHandshakeResultRejected = 1 // SYNC_HANDSHAKE_REJECTED = 1
} PEPSyncHandshakeResult;

typedef enum _PEPCommType {
    PEPCtUnknown = 0, // PEP_ct_unknown = 0,

    // range 0x01 to 0x09: no encryption, 0x0a to 0x0e: nothing reasonable

    PEPCtNoEncryption = 0x01, // PEP_ct_no_encryption = 0x01,                // generic
    PEPCtNoEncrypted_channel = 0x02, // PEP_ct_no_encrypted_channel = 0x02,
    PEPCtKeyNotFound = 0x03, // PEP_ct_key_not_found = 0x03,
    PEPCtKeyExpired = 0x04, // PEP_ct_key_expired = 0x04,
    PEPCtKeyRevoked = 0x05, // PEP_ct_key_revoked = 0x05,
    PEPCtKeyBr0ken = 0x06, // PEP_ct_key_b0rken = 0x06,
    PEPCtKeyExpiredButConfirmed = 0x07, // PEP_ct_key_expired_but_confirmed = 0x07, // NOT with confirmed bit. Just retaining info here in case of renewal.
    PEPCtMyKeyNotIncluded = 0x09, // PEP_ct_my_key_not_included = 0x09,

    PEPCtSecurityByObscurity = 0x0a, // PEP_ct_security_by_obscurity = 0x0a,
    PEPCtBr0kenCrypto = 0x0b, // PEP_ct_b0rken_crypto = 0x0b,
    PEPCtKeyTooShort = 0x0c, // PEP_ct_key_too_short = 0x0c,

    PEPCtCompromised = 0x0e, // PEP_ct_compromized = 0x0e,                  // deprecated misspelling
    PEPCtMistrusted = 0x0f, // PEP_ct_mistrusted = 0x0f,                   // known mistrusted key

    // range 0x10 to 0x3f: unconfirmed encryption

    PEPCtUnconfirmedEncryption = 0x10, // PEP_ct_unconfirmed_encryption = 0x10,       // generic
    PEPCtOpenPGPWeakUnconfirmed = 0x11, // PEP_ct_OpenPGP_weak_unconfirmed = 0x11,     // RSA 1024 is weak

    PEPCtToBeChecked = 0x20, // PEP_ct_to_be_checked = 0x20,                // generic
    PEPCtSMIMEUnconfirmed = 0x21, // PEP_ct_SMIME_unconfirmed = 0x21,
    PEPCtCMSUnconfirmed = 0x22, // PEP_ct_CMS_unconfirmed = 0x22,

    PEPCtStongButUnconfirmed = 0x30, // PEP_ct_strong_but_unconfirmed = 0x30,       // generic
    PEPCtOpenPGPUnconfirmed = 0x38, // PEP_ct_OpenPGP_unconfirmed = 0x38,          // key at least 2048 bit RSA or EC
    PEPCtOTRUnconfirmed = 0x3a, // PEP_ct_OTR_unconfirmed = 0x3a,

    // range 0x40 to 0x7f: unconfirmed encryption and anonymization

    PEPCtUnconfirmedEncAnon = 0x40, // PEP_ct_unconfirmed_enc_anon = 0x40,         // generic
    PEPCtPEPUnconfirmed = 0x7f, // PEP_ct_pEp_unconfirmed = 0x7f,

    PEPCtConfirmed = 0x80, // PEP_ct_confirmed = 0x80,                    // this bit decides if trust is confirmed

    // range 0x81 to 0x8f: reserved
    // range 0x90 to 0xbf: confirmed encryption

    PEPCtConfirmedEncryption = 0x90, // PEP_ct_confirmed_encryption = 0x90,         // generic
    PEPCtOpenPGPWeak = 0x91, // PEP_ct_OpenPGP_weak = 0x91,                 // RSA 1024 is weak (unused)

    PEPCtToBeCheckedConfirmed = 0xa0, // PEP_ct_to_be_checked_confirmed = 0xa0,      // generic
    PEPCtSMIME = 0xa1, // PEP_ct_SMIME = 0xa1,
    PEPCtCMS = 0xa2, // PEP_ct_CMS = 0xa2,

    PEPCtStongEncryption = 0xb0, // PEP_ct_strong_encryption = 0xb0,            // generic
    PEPCtOpenPGP = 0xb8, // PEP_ct_OpenPGP = 0xb8,                      // key at least 2048 bit RSA or EC
    PEPCtOTR = 0xba, // PEP_ct_OTR = 0xba,

    // range 0xc0 to 0xff: confirmed encryption and anonymization

    PEPCtConfirmedEncAnon = 0xc0, // PEP_ct_confirmed_enc_anon = 0xc0,           // generic
    PEPCtPEP = 0xff // PEP_ct_pEp = 0xff
} PEPCommType;

typedef enum _ObjC_PEP_msg_direction {
    PEPDirIncoming = 0,
    PEPDirOutgoing
} PEPMsgDirection;

typedef enum _ObjC_PEP_color {
    PEPColorNoColor = 0,
    PEPColorYellow,
    PEPColorGreen,
    PEPColorRed = -1,
} PEPColor;

typedef enum {
    PEPContentDispAttachment = 0,
    PEPContentDispInline = 1,
    PEPContentDispOther = -1      // must be affirmatively set
} PEPContentDisposition;

#endif /* PEPTypes_h */
