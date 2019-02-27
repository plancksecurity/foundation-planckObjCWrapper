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

#endif /* PEPConstants_h */
