//
//  PEPCommType.h
//  pEpObjCAdapterTypes
//
//  Created by Dirk Zimmermann on 30.11.20.
//

#ifndef PEPCommType_h
#define PEPCommType_h

typedef NS_CLOSED_ENUM(int, PEPCommType) {
    PEPCommTypeUnknown = 0, // PEP_ct_unknown
    PEPCommTypeNoEncryption = 0x01, // PEP_ct_no_encryption
    PEPCommTypeNoEncrypted_channel = 0x02, // PEP_ct_no_encrypted_channel
    PEPCommTypeKeyNotFound = 0x03, // PEP_ct_key_not_found
    PEPCommTypeKeyExpired = 0x04, // PEP_ct_key_expired
    PEPCommTypeKeyRevoked = 0x05, // PEP_ct_key_revoked
    PEPCommTypeKeyB0rken = 0x06, // PEP_ct_key_b0rken
    PEPCommTypeKeyExpiredButConfirmed = 0x07, // PEP_ct_key_expired_but_confirmed renewal.
    PEPCommTypeMyKeyNotIncluded = 0x09, // PEP_ct_my_key_not_included

    PEPCommTypeSecurityByObscurity = 0x0a, // PEP_ct_security_by_obscurity
    PEPCommTypeB0rkenCrypto = 0x0b, // PEP_ct_b0rken_crypto
    PEPCommTypeKeyTooShort = 0x0c, // PEP_ct_key_too_short

    PEPCommTypeCompromised = 0x0e, // PEP_ct_compromized
    PEPCommTypeMistrusted = 0x0f, // PEP_ct_mistrusted

    PEPCommTypeUnconfirmedEncryption = 0x10, // PEP_ct_unconfirmed_encryption
    PEPCommTypeOpenPGPWeakUnconfirmed = 0x11, // PEP_ct_OpenPGP_weak_unconfirmed

    PEPCommTypeToBeChecked = 0x20, // PEP_ct_to_be_checked
    PEPCommTypeSMIMEUnconfirmed = 0x21, // PEP_ct_SMIME_unconfirmed
    PEPCommTypeCMSUnconfirmed = 0x22, // PEP_ct_CMS_unconfirmed

    PEPCommTypeStongButUnconfirmed = 0x30, // PEP_ct_strong_but_unconfirmed
    PEPCommTypeOpenPGPUnconfirmed = 0x38, // PEP_ct_OpenPGP_unconfirmed
    PEPCommTypeOTRUnconfirmed = 0x3a, // PEP_ct_OTR_unconfirmed

    PEPCommTypeUnconfirmedEncAnon = 0x40, // PEP_ct_unconfirmed_enc_anon
    PEPCommTypePEPUnconfirmed = 0x7f, // PEP_ct_pEp_unconfirmed

    PEPCommTypeConfirmed = 0x80, // PEP_ct_confirmed

    PEPCommTypeConfirmedEncryption = 0x90, // PEP_ct_confirmed_encryption
    PEPCommTypeOpenPGPWeak = 0x91, // PEP_ct_OpenPGP_weak

    PEPCommTypeToBeCheckedConfirmed = 0xa0, // PEP_ct_to_be_checked_confirmed
    PEPCommTypeSMIME = 0xa1, // PEP_ct_SMIME
    PEPCommTypeCMS = 0xa2, // PEP_ct_CMS

    PEPCommTypeStongEncryption = 0xb0, // PEP_ct_strong_encryption
    PEPCommTypeOpenPGP = 0xb8, // PEP_ct_OpenPGP
    PEPCommTypeOTR = 0xba, // PEP_ct_OTR

    PEPCommTypeConfirmedEncAnon = 0xc0, // PEP_ct_confirmed_enc_anon
    PEPCommTypePEP = 0xff // PEP_ct_pEp
};

#endif /* PEPCommType_h */
