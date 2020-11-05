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
    PEPDecryptFlagsNonee = 0x0, // not actually defined in the engine
    PEPDecryptFlagsOwnPrivateKeye = 0x1, // PEP_decrypt_flag_own_private_key
    PEPDecryptFlagsConsumee = 0x2, //PEP_decrypt_flag_consume
    PEPDecryptFlagsIgnoree = 0x4, // PEP_decrypt_flag_ignore
    PEPDecryptFlagsSourceModifiede = 0x8, // PEP_decrypt_flag_src_modified
    PEPDecryptFlagsUntrustedServere = 0x100, // PEP_decrypt_flag_untrusted_server
    PEPDecryptFlagsDontTriggerSynce = 0x200, // PEP_decrypt_flag_dont_trigger_sync
};

typedef NS_CLOSED_ENUM(int, PEPEncFormat) {
    PEPEncFormatNonee = 0, // PEP_enc_none
    PEPEncFormatPiecese, // PEP_enc_pieces, PEP_enc_inline
    PEPEncFormatSMIMEe, // PEP_enc_S_MIME
    PEPEncFormatPGPMIMEe, // PEP_enc_PGP_MIME
    PEPEncFormatPEPe, // PEP_enc_PEP
    PEPEncFormatPGPMIMEOutlook1e // PEP_enc_PGP_MIME_Outlook1
};

typedef NS_CLOSED_ENUM(int, PEPRating) {
    PEPRatingUndefinede = 0, // PEP_rating_undefined
    PEPRatingCannotDecrypte = 1, // PEP_rating_cannot_decrypt
    PEPRatingHaveNoKeye = 2, // PEP_rating_have_no_key
    PEPRatingUnencryptede = 3, // PEP_rating_unencrypted
    PEPRatingUnreliablee = 5, // PEP_rating_unreliable
    PEPRatingReliablee = 6, // PEP_rating_reliable
    PEPRatingTrustede = 7, // PEP_rating_trusted
    PEPRatingTrustedAndAnonymizede = 8, // PEP_rating_trusted_and_anonymized
    PEPRatingFullyAnonymouse = 9, // PEP_rating_fully_anonymous

    PEPRatingMistruste = -1, // PEP_rating_mistrust
    PEPRatingB0rkene = -2, // PEP_rating_b0rken
    PEPRatingUnderAttacke = -3 // PEP_rating_under_attack
};

typedef NS_CLOSED_ENUM(int, PEPStatus) {
    PEPStatusOKe = 0, // PEP_STATUS_OK

    PEPStatusInitCannotLoadGPMEe = 0x0110, // PEP_INIT_CANNOT_LOAD_GPGME
    PEPStatusInitGPGMEInitFailede = 0x0111, // PEP_INIT_GPGME_INIT_FAILED
    PEPStatusInitNoGPGHomee = 0x0112, // PEP_INIT_NO_GPG_HOME
    PEPStatusInitNETPGPInitFailede = 0x0113, // PEP_INIT_NETPGP_INIT_FAILED
    PEPStatusInitCannotDetermineGPGVersione = 0x0114, // PEP_INIT_CANNOT_DETERMINE_GPG_VERSION
    PEPStatusInitUnsupportedGPGVersione = 0x0115, // PEP_INIT_UNSUPPORTED_GPG_VERSION
    PEPStatusInitCannotConfigGPGAgente = 0x0116, // PEP_INIT_CANNOT_CONFIG_GPG_AGENT

    PEPStatusInitSqlite3WithoutMutexe = 0x0120, // PEP_INIT_SQLITE3_WITHOUT_MUTEX
    PEPStatusInitCannotOpenDBe = 0x0121, // PEP_INIT_CANNOT_OPEN_DB
    PEPStatusInitCannotOpenSystemDBe = 0x0122, // PEP_INIT_CANNOT_OPEN_SYSTEM_DB
    PEPStatusUnknownDBErrore = 0x01ff, // PEP_UNKNOWN_DB_ERROR

    PEPStatusKeyNotFounde = 0x0201, // PEP_KEY_NOT_FOUND
    PEPStatusKeyHasAmbigNamee = 0x0202, // PEP_KEY_HAS_AMBIG_NAME
    PEPStatusGetKeyFailede = 0x0203, // PEP_GET_KEY_FAILED
    PEPStatusCannotExportKeye = 0x0204, // PEP_CANNOT_EXPORT_KEY
    PEPStatusCannotEditKeye = 0x0205, // PEP_CANNOT_EDIT_KEY
    PEPStatusKeyUnsuitablee = 0x0206, // PEP_KEY_UNSUITABLE
    PEPStatusMalformedKeyResetMsge = 0x0210, // PEP_MALFORMED_KEY_RESET_MSG
    PEPStatusKeyNotResete = 0x0211, // PEP_KEY_NOT_RESET
    PEPStatusCannotDeleteKeye = 0x0212, // PEP_CANNOT_DELETE_KEY

    PEPStatusKeyImportede = 0x0220, // PEP_KEY_IMPORTED
    PEPStatusNoKeyImportede = 0x0221, // PEP_NO_KEY_IMPORTED
    PEPStatusKeyImportStatusUnknowne = 0x0222, // PEP_KEY_IMPORT_STATUS_UNKNOWN
    PEPStatusSomeKeysImportede = 0x0223, // PEP_SOME_KEYS_IMPORTED

    PEPStatusCannotFindIdentitye = 0x0301, // PEP_CANNOT_FIND_IDENTITY
    PEPStatusCannotSetPersone = 0x0381, // PEP_CANNOT_SET_PERSON
    PEPStatusCannotSetPGPKeyPaire = 0x0382, // PEP_CANNOT_SET_PGP_KEYPAIR
    PEPStatusCannotSetIdentitye = 0x0383, // PEP_CANNOT_SET_IDENTITY
    PEPStatusCannotSetTruste = 0x0384, // PEP_CANNOT_SET_TRUST
    PEPStatusKeyBlacklistede = 0x0385, // PEP_KEY_BLACKLISTED
    PEPStatusCannotFindPersone = 0x0386, // PEP_CANNOT_FIND_PERSON
    PEPStatusCannotSetPEPVersione = 0X0387, // PEP_CANNOT_SET_PEP_VERSION

    PEPStatusCannotFindAliase = 0x0391, // PEP_CANNOT_FIND_ALIAS
    PEPStatusCannotSetAliase = 0x0392, // PEP_CANNOT_SET_ALIAS

    PEPStatusUnencryptede = 0x0400, // PEP_UNENCRYPTED
    PEPStatusVerifiede = 0x0401, // PEP_VERIFIED
    PEPStatusDecryptede = 0x0402, // PEP_DECRYPTED
    PEPStatusDecryptedAndVerifiede = 0x0403, // PEP_DECRYPTED_AND_VERIFIED
    PEPStatusDecryptWrongFormate = 0x0404, // PEP_DECRYPT_WRONG_FORMAT
    PEPStatusDecryptNoKeye = 0x0405, // PEP_DECRYPT_NO_KEY
    PEPStatusDecryptSignatureDoesNotMatche = 0x0406, // PEP_DECRYPT_SIGNATURE_DOES_NOT_MATCH
    PEPStatusVerifyNoKeye = 0x0407, // PEP_VERIFY_NO_KEY
    PEPStatusVerifiedAndTrustede = 0x0408, // PEP_VERIFIED_AND_TRUSTED
    PEPStatusCannotReencrypte = 0x0409, // PEP_CANNOT_REENCRYPT
    PEPStatusVerifySignerKeyRevokede = 0x040a, // PEP_VERIFY_SIGNER_KEY_REVOKED
    PEPStatusCannotDecryptUnknowne = 0x04ff, // PEP_CANNOT_DECRYPT_UNKNOWN

    PEPStatusTrustwordNotFounde = 0x0501, // PEP_TRUSTWORD_NOT_FOUND
    PEPStatusTrustwordsFPRWrongLengthe = 0x0502, // PEP_TRUSTWORDS_FPR_WRONG_LENGTH
    PEPStatusTrustwordsDuplicateFPRe = 0x0503, // PEP_TRUSTWORDS_DUPLICATE_FPR

    PEPStatusCannotCreateKeye = 0x0601, // PEP_CANNOT_CREATE_KEY
    PEPStatusCannotSendKeye = 0x0602, // PEP_CANNOT_SEND_KEY

    PEPStatusPhraseNotFounde = 0x0701, // PEP_PHRASE_NOT_FOUND

    PEPStatusSendFunctionNotRegisterede = 0x0801, // PEP_SEND_FUNCTION_NOT_REGISTERED
    PEPStatusConstraintsViolatede = 0x0802, // PEP_CONTRAINTS_VIOLATED
    PEPStatusCannotEncodee = 0x0803, // PEP_CANNOT_ENCODE

    PEPStatusSyncNoNotifyCallbacke = 0x0901, // PEP_SYNC_NO_NOTIFY_CALLBACK
    PEPStatusSyncIllegalMessagee = 0x0902, // PEP_SYNC_ILLEGAL_MESSAGE
    PEPStatusSyncNoInjectCallbacke = 0x0903, // PEP_SYNC_NO_INJECT_CALLBACK
    PEPStatusSyncNoChannele = 0x0904, // PEP_SYNC_NO_CHANNEL
    PEPStatusSyncCannotEncrypte = 0x0905, // PEP_SYNC_CANNOT_ENCRYPT
    PEPStatusSyncNoMessageSendCallbacke = 0x0906, // PEP_SYNC_NO_MESSAGE_SEND_CALLBACK
    PEPStatusSyncCannotStarte = 0x0907, // PEP_SYNC_CANNOT_START

    PEPStatusCannotIncreaseSequencee = 0x0971, // PEP_CANNOT_INCREASE_SEQUENCE

    PEPStatusStatemachineErrore = 0x0980, // PEP_STATEMACHINE_ERROR
    PEPStatusNoTruste = 0x0981, // PEP_NO_TRUST
    PEPStatusStatemachineInvalidStatee = 0x0982, // PEP_STATEMACHINE_INVALID_STATE
    PEPStatusStatemachineInvalidEvente = 0x0983, // PEP_STATEMACHINE_INVALID_EVENT
    PEPStatusStatemachineInvalidConditione = 0x0984, // PEP_STATEMACHINE_INVALID_CONDITION
    PEPStatusStatemachineInvalidActione = 0x0985, // PEP_STATEMACHINE_INVALID_ACTION
    PEPStatusStatemachineInhibitedEvente = 0x0986, // PEP_STATEMACHINE_INHIBITED_EVENT
    PEPStatusStatemachineCannotSende = 0x0987, // PEP_STATEMACHINE_CANNOT_SEND

    PEPStatusPassphraseRequirede = 0x0a00, // PEP_PASSPHRASE_REQUIRED
    PEPStatusWrongPassphrasee = 0x0a01, // PEP_WRONG_PASSPHRASE
    PEPStatusPassphraseForNewKeysRequirede = 0x0a02, // PEP_PASSPHRASE_FOR_NEW_KEYS_REQUIRED

    PEPStatusDistributionIllegalMessage = 0x1002, // PEP_DISTRIBUTION_ILLEGAL_MESSAGE,

    PEPStatusCommitFailede = 0xff01, // PEP_COMMIT_FAILED
    PEPStatusMessageConsumee = 0xff02, // PEP_MESSAGE_CONSUME
    PEPStatusMessageIgnoree = 0xff03, // PEP_MESSAGE_IGNORE
    PEPStatusCannotConfige = 0xff04, // PEP_CANNOT_CONFIG

    PEPStatusRecordNotFounde = -6, // PEP_RECORD_NOT_FOUND
    PEPStatusCannotCreateTempFilee = -5, // PEP_CANNOT_CREATE_TEMP_FILE
    PEPStatusIllegalValuee = -4, // PEP_ILLEGAL_VALUE
    PEPStatusBufferTooSmalle = -3, // PEP_BUFFER_TOO_SMALL
    PEPStatusOutOfMemorye = -2, // PEP_OUT_OF_MEMORY
    PEPStatusUnknownErrore = -1, // PEP_UNKNOWN_ERROR

    PEPStatusVersionMismatche = -7, // PEP_VERSION_MISMATCH
};

typedef NS_CLOSED_ENUM(int, PEPIdentityFlags) {
    PEPIdentityFlagsNotForSynce = 0x0001, // PEP_idf_not_for_sync
    PEPIdentityFlagsListe = 0x0002, // PEP_idf_list = 0x0002
    PEPIdentityFlagsDeviceGroupe = 0x0100 // PEP_idf_devicegroup
};

typedef NS_CLOSED_ENUM(int, PEPSyncHandshakeSignal) {
    PEPSyncHandshakeSignalUndefinede = 0, // SYNC_NOTIFY_UNDEFINED

    PEPSyncHandshakeSignalInitAddOurDevicee = 1, // SYNC_NOTIFY_INIT_ADD_OUR_DEVICE
    PEPSyncHandshakeSignalInitAddOtherDevicee = 2, // SYNC_NOTIFY_INIT_ADD_OTHER_DEVICE
    PEPSyncHandshakeSignalInitFormGroupe = 3, // SYNC_NOTIFY_INIT_FORM_GROUP

    PEPSyncHandshakeSignalTimeoute = 5, // SYNC_NOTIFY_TIMEOUT

    PEPSyncHandshakeSignalAcceptedDeviceAddede = 6, // SYNC_NOTIFY_ACCEPTED_DEVICE_ADDED
    PEPSyncHandshakeSignalAcceptedGroupCreatede = 7, // SYNC_NOTIFY_ACCEPTED_GROUP_CREATED

    PEPSyncHandshakeSignalAcceptedDeviceAcceptede = 8, // SYNC_NOTIFY_ACCEPTED_DEVICE_ACCEPTED

    PEPSyncHandshakeSignalPassphraseRequirede = 128, // SYNC_PASSPHRASE_REQUIRED

    PEPSyncHandshakeSignalSolee = 254, // SYNC_NOTIFY_SOLE
    PEPSyncHandshakeSignalInGroupe = 255 // SYNC_NOTIFY_IN_GROUP
};

typedef NS_CLOSED_ENUM(int, PEPSyncHandshakeResult) {
    PEPSyncHandshakeResultCancele = -1, // SYNC_HANDSHAKE_CANCEL
    PEPSyncHandshakeResultAcceptede = 0, // SYNC_HANDSHAKE_ACCEPTED
    PEPSyncHandshakeResultRejectede = 1 // SYNC_HANDSHAKE_REJECTED
};

typedef NS_CLOSED_ENUM(int, PEPCommType) {
    PEPCommTypeUnknowne = 0, // PEP_ct_unknown
    PEPCommTypeNoEncryptione = 0x01, // PEP_ct_no_encryption
    PEPCommTypeNoEncrypted_channele = 0x02, // PEP_ct_no_encrypted_channel
    PEPCommTypeKeyNotFounde = 0x03, // PEP_ct_key_not_found
    PEPCommTypeKeyExpirede = 0x04, // PEP_ct_key_expired
    PEPCommTypeKeyRevokede = 0x05, // PEP_ct_key_revoked
    PEPCommTypeKeyB0rkene = 0x06, // PEP_ct_key_b0rken
    PEPCommTypeKeyExpiredButConfirmede = 0x07, // PEP_ct_key_expired_but_confirmed renewal.
    PEPCommTypeMyKeyNotIncludede = 0x09, // PEP_ct_my_key_not_included

    PEPCommTypeSecurityByObscuritye = 0x0a, // PEP_ct_security_by_obscurity
    PEPCommTypeB0rkenCryptoe = 0x0b, // PEP_ct_b0rken_crypto
    PEPCommTypeKeyTooShorte = 0x0c, // PEP_ct_key_too_short

    PEPCommTypeCompromisede = 0x0e, // PEP_ct_compromized
    PEPCommTypeMistrustede = 0x0f, // PEP_ct_mistrusted

    PEPCommTypeUnconfirmedEncryptione = 0x10, // PEP_ct_unconfirmed_encryption
    PEPCommTypeOpenPGPWeakUnconfirmede = 0x11, // PEP_ct_OpenPGP_weak_unconfirmed

    PEPCommTypeToBeCheckede = 0x20, // PEP_ct_to_be_checked
    PEPCommTypeSMIMEUnconfirmede = 0x21, // PEP_ct_SMIME_unconfirmed
    PEPCommTypeCMSUnconfirmede = 0x22, // PEP_ct_CMS_unconfirmed

    PEPCommTypeStongButUnconfirmede = 0x30, // PEP_ct_strong_but_unconfirmed
    PEPCommTypeOpenPGPUnconfirmede = 0x38, // PEP_ct_OpenPGP_unconfirmed
    PEPCommTypeOTRUnconfirmede = 0x3a, // PEP_ct_OTR_unconfirmed

    PEPCommTypeUnconfirmedEncAnone = 0x40, // PEP_ct_unconfirmed_enc_anon
    PEPCommTypePEPUnconfirmede = 0x7f, // PEP_ct_pEp_unconfirmed

    PEPCommTypeConfirmede = 0x80, // PEP_ct_confirmed

    PEPCommTypeConfirmedEncryptione = 0x90, // PEP_ct_confirmed_encryption
    PEPCommTypeOpenPGPWeake = 0x91, // PEP_ct_OpenPGP_weak

    PEPCommTypeToBeCheckedConfirmede = 0xa0, // PEP_ct_to_be_checked_confirmed
    PEPCommTypeSMIMEe = 0xa1, // PEP_ct_SMIME
    PEPCommTypeCMSe = 0xa2, // PEP_ct_CMS

    PEPCommTypeStongEncryptione = 0xb0, // PEP_ct_strong_encryption
    PEPCommTypeOpenPGPe = 0xb8, // PEP_ct_OpenPGP
    PEPCommTypeOTRe = 0xba, // PEP_ct_OTR

    PEPCommTypeConfirmedEncAnone = 0xc0, // PEP_ct_confirmed_enc_anon
    PEPCommTypePEPe = 0xff // PEP_ct_pEp
};

typedef NS_CLOSED_ENUM(int, PEPMsgDirection) {
    PEPMsgDirectionIncominge = 0, // PEP_dir_incoming
    PEPMsgDirectionOutgoinge // PEP_dir_outgoing
};

typedef NS_CLOSED_ENUM(int, PEPColor) {
    PEPColorNoColore = 0, // PEP_color_no_color
    PEPColorYellowe, // PEP_color_yellow
    PEPColorGreene, // PEP_color_green
    PEPColorRede = -1, // PEP_color_red
};

typedef NS_CLOSED_ENUM(int, PEPContentDisposition) {
    PEPContentDispositionAttachmente = 0, // PEP_CONTENT_DISP_ATTACHMENT
    PEPContentDispositionInlinee = 1, // PEP_CONTENT_DISP_INLINE
    PEPContentDispositionOthere = -1 // PEP_CONTENT_DISP_OTHER
};

#endif /* PEPTypes_h */
