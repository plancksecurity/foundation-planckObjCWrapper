//
//  PEPEngineTypes.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 27.02.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#ifndef PEPEngineTypes_h
#define PEPEngineTypes_h

#import <Foundation/Foundation.h>

typedef NS_CLOSED_ENUM(NSUInteger, PEPTransportID) {
    PEPTransportIDTransportAuto = 0, // auto transport chooses transport per message automatically
    // Currently unsupported
//    PEPTransportIDTransportEmail = 0x01,
//    PEPTransportIDTransportRCE = 0x02,

    PEPTransportIDTransportSCTP = 0xfd,

    /// Used for figuring out the number of transport types.
    /// Which is all previously defined transport types plus one, the control channel.
    PEPTransportIDTransportCount,

    PEPTransportIDTransportCC = 0xfe
};

typedef NS_CLOSED_ENUM(int, PEPSyncHandshakeResult) {
    PEPSyncHandshakeResultCancel = -1, // SYNC_HANDSHAKE_CANCEL
    PEPSyncHandshakeResultAccepted = 0, // SYNC_HANDSHAKE_ACCEPTED
    PEPSyncHandshakeResultRejected = 1, // SYNC_HANDSHAKE_REJECTED
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
    PEPSyncHandshakeSignalOutgoingRatingChange = 64, // SYNC_NOTIFY_OUTGOING_RATING_CHANGE
    PEPSyncHandshakeSignalStart = 126, // SYNC_NOTIFY_START
    PEPSyncHandshakeSignalStop = 127, // SYNC_NOTIFY_STOP
    PEPSyncHandshakeSignalPassphraseRequired = 128, // SYNC_PASSPHRASE_REQUIRED
    PEPSyncHandshakeSignalSole = 254, // SYNC_NOTIFY_SOLE
    PEPSyncHandshakeSignalInGroup = 255, // SYNC_NOTIFY_IN_GROUP
};

typedef NS_CLOSED_ENUM(int, PEPContentDisposition) {
    PEPContentDispositionAttachment = 0, // PEP_CONTENT_DISP_ATTACHMENT
    PEPContentDispositionInline = 1, // PEP_CONTENT_DISP_INLINE
    PEPContentDispositionOther, // PEP_CONTENT_DISP_OTHER
};

typedef NS_CLOSED_ENUM(int, PEPMsgDirection) {
    PEPMsgDirectionIncoming = 0, // PEP_dir_incoming
    PEPMsgDirectionOutgoing, // PEP_dir_outgoing
};

typedef NS_CLOSED_ENUM(int, PEPTextFormat) {
    PEPTextFormatPlain = 0, // PEP_text_format_plain
    PEPTextFormatHtml, // PEP_text_format_html
    PEPTextFormatOther = 0xff, // PEP_text_format_other
};

typedef NS_CLOSED_ENUM(int, PEPDecryptFlags) {
    PEPDecryptFlagsNone = 0x0, // not actually defined in the engine
    PEPDecryptFlagsOwnPrivateKey = 0x1, // PEP_decrypt_flag_own_private_key
    PEPDecryptFlagsConsume = 0x2, // PEP_decrypt_flag_consume
    PEPDecryptFlagsIgnore = 0x4, // PEP_decrypt_flag_ignore
    PEPDecryptFlagsSrcModified = 0x8, // PEP_decrypt_flag_src_modified
    PEPDecryptFlagsUntrustedServer = 0x100, // PEP_decrypt_flag_untrusted_server
    PEPDecryptFlagsDontTriggerSync = 0x200, // PEP_decrypt_flag_dont_trigger_sync
};

typedef NS_CLOSED_ENUM(int, PEPColor) {
    PEPColorNoColor = 0, // PEP_color_no_color
    PEPColorYellow, // PEP_color_yellow
    PEPColorGreen, // PEP_color_green
    PEPColorRed = -1, // PEP_color_red
};

typedef NS_CLOSED_ENUM(int, PEPRating) {
    PEPRatingUndefined = 0, // PEP_rating_undefined
    PEPRatingCannotDecrypt = 1, // PEP_rating_cannot_decrypt
    PEPRatingHaveNoKey = 2, // PEP_rating_have_no_key
    PEPRatingUnencrypted = 3, // PEP_rating_unencrypted
    PEPRatingUnreliable = 5, // PEP_rating_unreliable

    // Keep the rating definition for the app, even though media keys
    // are not actively used.
    // Engine Release_2.1.64, media_key.c:
    // `const PEP_rating media_key_message_rating = PEP_rating_unreliable`
    PEPRatingMediaKeyProtected = 6,

    PEPRatingB0rken = -2, // PEP_rating_b0rken
    PEPRatingReliable = 6, // PEP_rating_reliable
    PEPRatingTrusted = 7, // PEP_rating_trusted
    PEPRatingTrustedAndAnonymized = 8, // PEP_rating_trusted_and_anonymized
    PEPRatingFullyAnonymous = 9, // PEP_rating_fully_anonymous
    PEPRatingMistrust = -1, // PEP_rating_mistrust
    PEPRatingUnderAttack = -3, // PEP_rating_under_attack
};

typedef NS_CLOSED_ENUM(int, PEPMessageWrapType) {
    PEPMessageWrapTypeUnwrapped, // PEP_message_unwrapped
    PEPMessageWrapTypeDefault, // PEP_message_default
    PEPMessageWrapTypeTransport, // PEP_message_transport
    PEPMessageWrapTypeKeyReset, // PEP_message_key_reset
};

typedef NS_CLOSED_ENUM(int, PEPEncryptFlags) {
    PEPEncryptFlagsDefault = 0x0, // PEP_encrypt_flag_default
    PEPEncryptFlagsForceEncryption = 0x1, // PEP_encrypt_flag_force_encryption
    PEPEncryptFlagsForceUnsigned = 0x2, // PEP_encrypt_flag_force_unsigned
    PEPEncryptFlagsForceNoAttachedKey = 0x4, // PEP_encrypt_flag_force_no_attached_key
    PEPEncryptFlagsInnerMessage = 0x8, // PEP_encrypt_flag_inner_message
    // this, // // This
    PEPEncryptFlagsForceVersion1 = 0x10, // PEP_encrypt_flag_force_version_1
    PEPEncryptFlagsKeyResetOnly = 0x20, // PEP_encrypt_flag_key_reset_only
    PEPEncryptReencrypt = 0x40, // PEP_encrypt_reencrypt
};

typedef NS_CLOSED_ENUM(int, PEPIdentityFlags) {
    PEPIdentityFlagsNotForSync, // PEP_idf_not_for_sync
    PEPIdentityFlagsList, // PEP_idf_list
    PEPIdentityFlagsDevicegroup, // PEP_idf_devicegroup
};

typedef NS_CLOSED_ENUM(int, PEPCommType) {
    PEPCommTypeUnknown = 0, // PEP_ct_unknown
    PEPCommTypeNoEncryption, // PEP_ct_no_encryption
    PEPCommTypeNoEncryptedChannel = 0x02, // PEP_ct_no_encrypted_channel
    PEPCommTypeKeyNotFound = 0x03, // PEP_ct_key_not_found
    PEPCommTypeKeyExpired = 0x04, // PEP_ct_key_expired
    PEPCommTypeKeyRevoked = 0x05, // PEP_ct_key_revoked
    PEPCommTypeKeyB0rken = 0x06, // PEP_ct_key_b0rken
    PEPCommTypeKeyExpiredButConfirmed, // PEP_ct_key_expired_but_confirmed
    PEPCommTypeMyKeyNotIncluded = 0x09, // PEP_ct_my_key_not_included
    PEPCommTypeSecurityByObscurity = 0x0a, // PEP_ct_security_by_obscurity
    PEPCommTypeB0rkenCrypto = 0x0b, // PEP_ct_b0rken_crypto
    PEPCommTypeKeyTooShort = 0x0c, // PEP_ct_key_too_short
    PEPCommTypeCompromised, // PEP_ct_compromised
    PEPCommTypeCompromized, // PEP_ct_compromized
    PEPCommTypeMistrusted, // PEP_ct_mistrusted
    PEPCommTypeUnconfirmedEncryption, // PEP_ct_unconfirmed_encryption
    PEPCommTypeOpenPGPWeakUnconfirmed, // PEP_ct_OpenPGP_weak_unconfirmed
    PEPCommTypeToBeChecked, // PEP_ct_to_be_checked
    PEPCommTypeSmimeUnconfirmed = 0x21, // PEP_ct_SMIME_unconfirmed
    PEPCommTypeCmsUnconfirmed = 0x22, // PEP_ct_CMS_unconfirmed
    PEPCommTypeStrongButUnconfirmed, // PEP_ct_strong_but_unconfirmed
    PEPCommTypeOpenPGPUnconfirmed, // PEP_ct_OpenPGP_unconfirmed
    PEPCommTypeOtrUnconfirmed = 0x3a, // PEP_ct_OTR_unconfirmed
    PEPCommTypeUnconfirmedEncAnon, // PEP_ct_unconfirmed_enc_anon
    PEPCommTypePEPUnconfirmed = 0x7f, // PEP_ct_pEp_unconfirmed
    PEPCommTypeConfirmed, // PEP_ct_confirmed
    PEPCommTypeConfirmedEncryption, // PEP_ct_confirmed_encryption
    PEPCommTypeOpenPGPWeak, // PEP_ct_OpenPGP_weak
    PEPCommTypeToBeCheckedConfirmed, // PEP_ct_to_be_checked_confirmed
    PEPCommTypeSmime = 0xa1, // PEP_ct_SMIME
    PEPCommTypeCms = 0xa2, // PEP_ct_CMS
    PEPCommTypeStrongEncryption, // PEP_ct_strong_encryption
    PEPCommTypeOpenPGP, // PEP_ct_OpenPGP
    PEPCommTypeOtr = 0xba, // PEP_ct_OTR
    PEPCommTypeConfirmedEncAnon, // PEP_ct_confirmed_enc_anon
    PEPCommTypePEP = 0xff, // PEP_ct_pEp
};

typedef NS_CLOSED_ENUM(int, PEPCipherSuite) {
    PEPCipherSuiteDefault = 0, // PEP_CIPHER_SUITE_DEFAULT
    PEPCipherSuiteCv25519 = 1, // PEP_CIPHER_SUITE_CV25519
    PEPCipherSuiteP256 = 2, // PEP_CIPHER_SUITE_P256
    PEPCipherSuiteP384 = 3, // PEP_CIPHER_SUITE_P384
    PEPCipherSuiteP521 = 4, // PEP_CIPHER_SUITE_P521
    PEPCipherSuiteRsa2k = 5, // PEP_CIPHER_SUITE_RSA2K
    PEPCipherSuiteRsa3k = 6, // PEP_CIPHER_SUITE_RSA3K
    PEPCipherSuiteRsa4k = 7, // PEP_CIPHER_SUITE_RSA4K
    PEPCipherSuiteRsa8k = 8, // PEP_CIPHER_SUITE_RSA8K
};

typedef NS_CLOSED_ENUM(int, PEPEncFormat) {
    PEPEncFormatNone, // PEP_enc_none
    PEPEncFormatPieces, // PEP_enc_pieces
    PEPEncFormatInline, // PEP_enc_inline
    PEPEncFormatSMime, // PEP_enc_S_MIME
    PEPEncFormatPGPMime, // PEP_enc_PGP_MIME
    PEPEncFormatPEP, // PEP_enc_PEP
    PEPEncFormatPGPMimeOutlook1, // PEP_enc_PGP_MIME_Outlook1
    PEPEncFormatInlineEa, // PEP_enc_inline_EA
    PEPEncFormatAuto, // PEP_enc_auto
};

typedef NS_CLOSED_ENUM(int, PEPStatus) {
    PEPStatusOK = 0, // PEP_STATUS_OK
    PEPStatusInitCannotLoadCryptoLib = 0x0110, // PEP_INIT_CANNOT_LOAD_CRYPTO_LIB
    PEPStatusInitCryptoLibInitFailed = 0x0111, // PEP_INIT_CRYPTO_LIB_INIT_FAILED
    PEPStatusInitNoCryptoHome = 0x0112, // PEP_INIT_NO_CRYPTO_HOME
    PEPStatusInitCannotDetermineCryptoVersion = 0x0114, // PEP_INIT_CANNOT_DETERMINE_CRYPTO_VERSION
    PEPStatusInitUnsupportedCryptoVersion = 0x0115, // PEP_INIT_UNSUPPORTED_CRYPTO_VERSION
    PEPStatusInitCannotConfigCryptoAgent = 0x0116, // PEP_INIT_CANNOT_CONFIG_CRYPTO_AGENT
    PEPStatusInitSqlite3WithoutMutex = 0x0120, // PEP_INIT_SQLITE3_WITHOUT_MUTEX
    PEPStatusInitCannotOpenDB = 0x0121, // PEP_INIT_CANNOT_OPEN_DB
    PEPStatusInitCannotOpenSystemDB = 0x0122, // PEP_INIT_CANNOT_OPEN_SYSTEM_DB
    PEPStatusInitDBDowngradeViolation = 0x0123, // PEP_INIT_DB_DOWNGRADE_VIOLATION
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
    PEPStatusCannotSetPGPKeypair = 0x0382, // PEP_CANNOT_SET_PGP_KEYPAIR
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
    PEPStatusTrustwordsFprWrongLength = 0x0502, // PEP_TRUSTWORDS_FPR_WRONG_LENGTH
    PEPStatusTrustwordsDuplicateFpr = 0x0503, // PEP_TRUSTWORDS_DUPLICATE_FPR
    PEPStatusCannotCreateKey = 0x0601, // PEP_CANNOT_CREATE_KEY
    PEPStatusCannotSendKey = 0x0602, // PEP_CANNOT_SEND_KEY
    PEPStatusPhraseNotFound = 0x0701, // PEP_PHRASE_NOT_FOUND
    PEPStatusSendFunctionNotRegistered = 0x0801, // PEP_SEND_FUNCTION_NOT_REGISTERED
    PEPStatusContraintsViolated = 0x0802, // PEP_CONTRAINTS_VIOLATED
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
    PEPStatusDistributionIllegalMessage = 0x1002, // PEP_DISTRIBUTION_ILLEGAL_MESSAGE
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

#endif /* PEPEngineTypes_h */
