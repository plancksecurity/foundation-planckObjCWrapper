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

typedef NS_CLOSED_ENUM(int, PEPDecryptFlags) {
    PEPDecryptFlagsNone = 0x0, // not actually defined in the engine
    PEPDecryptFlagsOwnPrivateKey = 0x1, // PEP_decrypt_flag_own_private_key
    PEPDecryptFlagsConsume = 0x2, //PEP_decrypt_flag_consume
    PEPDecryptFlagsIgnore = 0x4, // PEP_decrypt_flag_ignore
    PEPDecryptFlagsSourceModified = 0x8, // PEP_decrypt_flag_src_modified
    PEPDecryptFlagsUntrustedServer = 0x100, // PEP_decrypt_flag_untrusted_server
    PEPDecryptFlagsDontTriggerSync = 0x200, // PEP_decrypt_flag_dont_trigger_sync
};

typedef NS_ENUM(int, PEPEncFormat) {
    PEPEncFormatNone = 0, // PEP_enc_none = 0, // message is not encrypted
    PEPEncFormatPieces, // PEP_enc_pieces, // inline PGP + PGP extensions
    PEPEncFormatSMIME, // PEP_enc_S_MIME, // RFC5751
    PEPEncFormatPgpMIME, // PEP_enc_PGP_MIME, // RFC3156
    PEPEncFormatPEP, // PEP_enc_PEP, // pEp encryption format
    PEPEncFormatPgpMIMEOutlook1 // PEP_enc_PGP_MIME_Outlook1 // Message B0rken by Outlook type 1
};

typedef NS_ENUM(int, PEPRating) {
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
};

typedef NS_ENUM(int, PEPStatus) {
    PEPStatusOK                                   = 0, // PEP_STATUS_OK

    PEPStatusInitCannotLoadGPME                      = 0x0110, // PEP_INIT_CANNOT_LOAD_GPGME
    PEPStatusInitGPGMEInitFailed                      = 0x0111, // PEP_INIT_GPGME_INIT_FAILED
    PEPStatusInitNoGPGHome                            = 0x0112, // PEP_INIT_NO_GPG_HOME
    PEPStatusInitNETPGPInitFailed                     = 0x0113, // PEP_INIT_NETPGP_INIT_FAILED
    PEPStatusInitCannotDetermineGPGVersion           = 0x0114, // PEP_INIT_CANNOT_DETERMINE_GPG_VERSION
    PEPStatusInitUnsupportedGPGVersion                = 0x0115, // PEP_INIT_UNSUPPORTED_GPG_VERSION
    PEPStatusInitCannotConfigGPGAgent                = 0x0116, // PEP_INIT_CANNOT_CONFIG_GPG_AGENT

    PEPStatusInitSqlite3WithoutMutex                  = 0x0120, // PEP_INIT_SQLITE3_WITHOUT_MUTEX
    PEPStatusInitCannotOpenDB                         = 0x0121, // PEP_INIT_CANNOT_OPEN_DB
    PEPStatusInitCannotOpenSystemDB                  = 0x0122, // PEP_INIT_CANNOT_OPEN_SYSTEM_DB
    PEPStatusUnknownDBError                            = 0x01ff, // PEP_UNKNOWN_DB_ERROR

    PEPStatusKeyNotFound                               = 0x0201, // PEP_KEY_NOT_FOUND
    PEPStatusKeyHasAmbigName                          = 0x0202, // PEP_KEY_HAS_AMBIG_NAME
    PEPStatusGetKeyFailed                              = 0x0203, // PEP_GET_KEY_FAILED
    PEPStatusCannotExportKey                           = 0x0204, // PEP_CANNOT_EXPORT_KEY
    PEPStatusCannotEditKey                             = 0x0205, // PEP_CANNOT_EDIT_KEY
    PEPStatusKeyUnsuitable                              = 0x0206, // PEP_KEY_UNSUITABLE
    PEPStatusMalformedKeyResetMsg                     = 0x0210, // PEP_MALFORMED_KEY_RESET_MSG
    PEPStatusKeyNotReset                               = 0x0211, // PEP_KEY_NOT_RESET

    PEPStatusKeyImported                                = 0x0220, // PEP_KEY_IMPORTED
    PEPStatusNoKeyImported                             = 0x0221, // PEP_NO_KEY_IMPORTED
    PEPStatusKeyImportStatusUnknown                   = 0x0222, // PEP_KEY_IMPORT_STATUS_UNKNOWN

    PEPStatusCannotFindIdentity                        = 0x0301, // PEP_CANNOT_FIND_IDENTITY
    PEPStatusCannotSetPerson                           = 0x0381, // PEP_CANNOT_SET_PERSON
    PEPStatusCannotSetPGPKeyPair                      = 0x0382, // PEP_CANNOT_SET_PGP_KEYPAIR
    PEPStatusCannotSetIdentity                         = 0x0383, // PEP_CANNOT_SET_IDENTITY
    PEPStatusCannotSetTrust                            = 0x0384, // PEP_CANNOT_SET_TRUST
    PEPStatusKeyBlacklisted                             = 0x0385, // PEP_KEY_BLACKLISTED
    PEPStatusCannotFindPerson                          = 0x0386, // PEP_CANNOT_FIND_PERSON
    PEPStatusCannotSetPEPVersion = 0X0387, // PEP_CANNOT_SET_PEP_VERSION

    PEPStatusCannotFindAlias                           = 0x0391, // PEP_CANNOT_FIND_ALIAS
    PEPStatusCannotSetAlias                            = 0x0392, // PEP_CANNOT_SET_ALIAS

    PEPStatusUnencrypted                                 = 0x0400, // PEP_UNENCRYPTED
    PEPStatusVerified                                    = 0x0401, // PEP_VERIFIED
    PEPStatusDecrypted                                   = 0x0402, // PEP_DECRYPTED
    PEPStatusDecryptedAndVerified                      = 0x0403, // PEP_DECRYPTED_AND_VERIFIED
    PEPStatusDecryptWrongFormat                        = 0x0404, // PEP_DECRYPT_WRONG_FORMAT
    PEPStatusDecryptNoKey                              = 0x0405, // PEP_DECRYPT_NO_KEY
    PEPStatusDecryptSignatureDoesNotMatch            = 0x0406, // PEP_DECRYPT_SIGNATURE_DOES_NOT_MATCH
    PEPStatusVerifyNoKey                               = 0x0407, // PEP_VERIFY_NO_KEY
    PEPStatusVerifiedAndTrusted                        = 0x0408, // PEP_VERIFIED_AND_TRUSTED
    PEPStatusCannotReencrypt                            = 0x0409, // PEP_CANNOT_REENCRYPT
    PEPStatusCannotDecryptUnknown                      = 0x04ff, // PEP_CANNOT_DECRYPT_UNKNOWN

    PEPStatusTrustwordNotFound                         = 0x0501, // PEP_TRUSTWORD_NOT_FOUND
    PEPStatusTrustwordsFPRWrongLength                 = 0x0502, // PEP_TRUSTWORDS_FPR_WRONG_LENGTH
    PEPStatusTrustwordsDuplicateFPR                    = 0x0503, // PEP_TRUSTWORDS_DUPLICATE_FPR

    PEPStatusCannotCreateKey                           = 0x0601, // PEP_CANNOT_CREATE_KEY
    PEPStatusCannotSendKey                             = 0x0602, // PEP_CANNOT_SEND_KEY

    PEPStatusPhraseNotFound                            = 0x0701, // PEP_PHRASE_NOT_FOUND

    PEPStatusSendFunctionNotRegistered                = 0x0801, // PEP_SEND_FUNCTION_NOT_REGISTERED
    PEPStatusConstraintsViolated                         = 0x0802, // PEP_CONTRAINTS_VIOLATED
    PEPStatusCannotEncode                               = 0x0803, // PEP_CANNOT_ENCODE

    PEPStatusSyncNoNotifyCallback                     = 0x0901, // PEP_SYNC_NO_NOTIFY_CALLBACK
    PEPStatusSyncIllegalMessage                        = 0x0902, // PEP_SYNC_ILLEGAL_MESSAGE
    PEPStatusSyncNoInjectCallback                     = 0x0903, // PEP_SYNC_NO_INJECT_CALLBACK
    PEPStatusSyncNoChannel                             = 0x0904, // PEP_SYNC_NO_CHANNEL
    PEPStatusSyncCannotEncrypt                         = 0x0905, // PEP_SYNC_CANNOT_ENCRYPT
    PEPStatusSyncNoMessageSendCallback               = 0x0906, // PEP_SYNC_NO_MESSAGE_SEND_CALLBACK

    PEPStatusCannotIncreaseSequence                    = 0x0971, // PEP_CANNOT_INCREASE_SEQUENCE

    PEPStatusStatemachineError                          = 0x0980, // PEP_STATEMACHINE_ERROR
    PEPStatusNoTrust                                    = 0x0981, // PEP_NO_TRUST
    PEPStatusStatemachineInvalidState                  = 0x0982, // PEP_STATEMACHINE_INVALID_STATE
    PEPStatusStatemachineInvalidEvent                  = 0x0983, // PEP_STATEMACHINE_INVALID_EVENT
    PEPStatusStatemachineInvalidCondition              = 0x0984, // PEP_STATEMACHINE_INVALID_CONDITION
    PEPStatusStatemachineInvalidAction                 = 0x0985, // PEP_STATEMACHINE_INVALID_ACTION
    PEPStatusStatemachineInhibitedEvent                = 0x0986, // PEP_STATEMACHINE_INHIBITED_EVENT
    PEPStatusStatemachineCannotSend                    = 0x0987, // PEP_STATEMACHINE_CANNOT_SEND

    PEPStatusCommitFailed                               = 0xff01, // PEP_COMMIT_FAILED
    PEPStatusMessageConsume                             = 0xff02, // PEP_MESSAGE_CONSUME
    PEPStatusMessageIgnore                              = 0xff03, // PEP_MESSAGE_IGNORE

    PEPStatusRecordNotFound                            = -6, // PEP_RECORD_NOT_FOUND
    PEPStatusCannotCreateTempFile                     = -5, // PEP_CANNOT_CREATE_TEMP_FILE
    PEPStatusIllegalValue                               = -4, // PEP_ILLEGAL_VALUE
    PEPStatusBufferTooSmall                            = -3, // PEP_BUFFER_TOO_SMALL
    PEPStatusOutOfMemory                               = -2, // PEP_OUT_OF_MEMORY
    PEPStatusUnknownError                               = -1, // PEP_UNKNOWN_ERROR

    PEPStatusVersionMismatch                            = -7, // PEP_VERSION_MISMATCH
};

typedef NS_ENUM(int, PEPIdentityFlags) {
    // the first octet flags are app defined settings
    PEPIdentityFlagsNotForSync = 0x0001, // PEP_idf_not_for_sync = 0x0001,   // don't use this identity for sync
    PEPIdentityFlagsList = 0x0002, // PEP_idf_list = 0x0002,           // identity of list of persons
    // the second octet flags are calculated
    PEPIdentityFlagsDeviceGroup = 0x0100 // PEP_idf_devicegroup = 0x0100     // identity of a device group member
};

typedef NS_ENUM(int, PEPSyncHandshakeSignal) { // _sync_handshake_signal
    PEPSyncHandshakeSignalUndefined = 0, // SYNC_NOTIFY_UNDEFINED = 0,

    // request show handshake dialog
    PEPSyncHandshakeSignalInitAddOurDevice = 1, // SYNC_NOTIFY_INIT_ADD_OUR_DEVICE = 1,
    PEPSyncHandshakeSignalInitAddOtherDevice = 2, // SYNC_NOTIFY_INIT_ADD_OTHER_DEVICE = 2,
    PEPSyncHandshakeSignalInitFormGroup = 3, // SYNC_NOTIFY_INIT_FORM_GROUP = 3,
    // SYNC_NOTIFY_INIT_MOVE_OUR_DEVICE = 4,

    // handshake process timed out
    PEPSyncHandshakeSignalTimeout = 5, // SYNC_NOTIFY_TIMEOUT = 5,

    // handshake accepted by user
    PEPSyncHandshakeSignalAcceptedDeviceAdded = 6, // SYNC_NOTIFY_ACCEPTED_DEVICE_ADDED = 6,
    PEPSyncHandshakeSignalAcceptedGroupCreated = 7, // SYNC_NOTIFY_ACCEPTED_GROUP_CREATED = 7,
    // SYNC_NOTIFY_ACCEPTED_DEVICE_MOVED = 8,

    // handshake dialog must be closed
    PEPSyncHandshakeSignalOvertaken = 9, // SYNC_NOTIFY_OVERTAKEN = 9,

    /** currently exchanging private keys */
    PEPSyncHandshakeSignalFormingGroup = 10, // SYNC_NOTIFY_FORMING_GROUP = 10

    // notificaton of actual group status
    PEPSyncHandshakeSignalSole = 254, // SYNC_NOTIFY_SOLE = 254,
    PEPSyncHandshakeSignalInGroup = 255 // SYNC_NOTIFY_IN_GROUP = 255
};

typedef NS_ENUM(int, PEPSyncHandshakeResult) {
    PEPSyncHandshakeResultCancel = -1, // SYNC_HANDSHAKE_CANCEL = -1,
    PEPSyncHandshakeResultAccepted = 0, // SYNC_HANDSHAKE_ACCEPTED = 0,
    PEPSyncHandshakeResultRejected = 1 // SYNC_HANDSHAKE_REJECTED = 1
};

typedef NS_ENUM(int, PEPCommType) {
    PEPCommTypeUnknown = 0, // PEP_ct_unknown = 0,

    // range 0x01 to 0x09: no encryption, 0x0a to 0x0e: nothing reasonable

    PEPCommTypeNoEncryption = 0x01, // PEP_ct_no_encryption = 0x01,                // generic
    PEPCommTypeNoEncrypted_channel = 0x02, // PEP_ct_no_encrypted_channel = 0x02,
    PEPCommTypeKeyNotFound = 0x03, // PEP_ct_key_not_found = 0x03,
    PEPCommTypeKeyExpired = 0x04, // PEP_ct_key_expired = 0x04,
    PEPCommTypeKeyRevoked = 0x05, // PEP_ct_key_revoked = 0x05,
    PEPCommTypeKeyBr0ken = 0x06, // PEP_ct_key_b0rken = 0x06,
    PEPCommTypeKeyExpiredButConfirmed = 0x07, // PEP_ct_key_expired_but_confirmed = 0x07, // NOT with confirmed bit. Just retaining info here in case of renewal.
    PEPCommTypeMyKeyNotIncluded = 0x09, // PEP_ct_my_key_not_included = 0x09,

    PEPCommTypeSecurityByObscurity = 0x0a, // PEP_ct_security_by_obscurity = 0x0a,
    PEPCommTypeBr0kenCrypto = 0x0b, // PEP_ct_b0rken_crypto = 0x0b,
    PEPCommTypeKeyTooShort = 0x0c, // PEP_ct_key_too_short = 0x0c,

    PEPCommTypeCompromised = 0x0e, // PEP_ct_compromized = 0x0e,                  // deprecated misspelling
    PEPCommTypeMistrusted = 0x0f, // PEP_ct_mistrusted = 0x0f,                   // known mistrusted key

    // range 0x10 to 0x3f: unconfirmed encryption

    PEPCommTypeUnconfirmedEncryption = 0x10, // PEP_ct_unconfirmed_encryption = 0x10,       // generic
    PEPCommTypeOpenPGPWeakUnconfirmed = 0x11, // PEP_ct_OpenPGP_weak_unconfirmed = 0x11,     // RSA 1024 is weak

    PEPCommTypeToBeChecked = 0x20, // PEP_ct_to_be_checked = 0x20,                // generic
    PEPCommTypeSMIMEUnconfirmed = 0x21, // PEP_ct_SMIME_unconfirmed = 0x21,
    PEPCommTypeCMSUnconfirmed = 0x22, // PEP_ct_CMS_unconfirmed = 0x22,

    PEPCommTypeStongButUnconfirmed = 0x30, // PEP_ct_strong_but_unconfirmed = 0x30,       // generic
    PEPCommTypeOpenPGPUnconfirmed = 0x38, // PEP_ct_OpenPGP_unconfirmed = 0x38,          // key at least 2048 bit RSA or EC
    PEPCommTypeOTRUnconfirmed = 0x3a, // PEP_ct_OTR_unconfirmed = 0x3a,

    // range 0x40 to 0x7f: unconfirmed encryption and anonymization

    PEPCommTypeUnconfirmedEncAnon = 0x40, // PEP_ct_unconfirmed_enc_anon = 0x40,         // generic
    PEPCommTypePEPUnconfirmed = 0x7f, // PEP_ct_pEp_unconfirmed = 0x7f,

    PEPCommTypeConfirmed = 0x80, // PEP_ct_confirmed = 0x80,                    // this bit decides if trust is confirmed

    // range 0x81 to 0x8f: reserved
    // range 0x90 to 0xbf: confirmed encryption

    PEPCommTypeConfirmedEncryption = 0x90, // PEP_ct_confirmed_encryption = 0x90,         // generic
    PEPCommTypeOpenPGPWeak = 0x91, // PEP_ct_OpenPGP_weak = 0x91,                 // RSA 1024 is weak (unused)

    PEPCommTypeToBeCheckedConfirmed = 0xa0, // PEP_ct_to_be_checked_confirmed = 0xa0,      // generic
    PEPCommTypeSMIME = 0xa1, // PEP_ct_SMIME = 0xa1,
    PEPCommTypeCMS = 0xa2, // PEP_ct_CMS = 0xa2,

    PEPCommTypeStongEncryption = 0xb0, // PEP_ct_strong_encryption = 0xb0,            // generic
    PEPCommTypeOpenPGP = 0xb8, // PEP_ct_OpenPGP = 0xb8,                      // key at least 2048 bit RSA or EC
    PEPCommTypeOTR = 0xba, // PEP_ct_OTR = 0xba,

    // range 0xc0 to 0xff: confirmed encryption and anonymization

    PEPCommTypeConfirmedEncAnon = 0xc0, // PEP_ct_confirmed_enc_anon = 0xc0,           // generic
    PEPCommTypePEP = 0xff // PEP_ct_pEp = 0xff
};

typedef NS_ENUM(int, PEPMsgDirection) {
    PEPMsgDirectionIncoming = 0,
    PEPMsgDirectionOutgoing
};

typedef NS_ENUM(int, PEPColor) {
    PEPColorNoColor = 0,
    PEPColorYellow,
    PEPColorGreen,
    PEPColorRed = -1,
};

typedef NS_ENUM(int, PEPContentDisposition) {
    PEPContentDispositionAttachment = 0,
    PEPContentDispositionInline = 1,
    PEPContentDispositionOther = -1      // must be affirmatively set
};

#endif /* PEPTypes_h */
