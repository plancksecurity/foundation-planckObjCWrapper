//
//  PEPConstants.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 27.02.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#ifndef PEPConstants_h
#define PEPConstants_h

typedef enum _PEP_decrypt_flags {
    PEPDecryptFlagOwnPrivateKey = 0x1, // PEP_decrypt_flag_own_private_key = 0x1,
    PEPDecryptFlagConsume = 0x2, // PEP_decrypt_flag_consume = 0x2,
    PEPDecryptFlagIgnore = 0x4, // PEP_decrypt_flag_ignore = 0x4,
    PEPDecryptFlagSrcModified = 0x8, // PEP_decrypt_flag_src_modified = 0x8,
    // input flags
    PEPDecryptFlagUntrustedServer = 0x100 // PEP_decrypt_flag_untrusted_server = 0x100
} PEPDecryptFlags; // PEP_decrypt_flags;

typedef enum _PEP_enc_format {
    PEPEncNone = 0, // PEP_enc_none = 0, // message is not encrypted
    PEPEncPieces, // PEP_enc_pieces, // inline PGP + PGP extensions
    PEPEncSMIME, // PEP_enc_S_MIME, // RFC5751
    PEPEncPGPMIME, // PEP_enc_PGP_MIME, // RFC3156
    PEPEncPEP, // PEP_enc_PEP, // pEp encryption format
    PEPEncPGPMIMEOutlook1 // PEP_enc_PGP_MIME_Outlook1 // Message B0rken by Outlook type 1
} PEPEncFormat;

typedef enum _PEP_rating {
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

#endif /* PEPConstants_h */
