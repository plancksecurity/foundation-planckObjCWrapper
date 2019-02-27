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

#endif /* PEPConstants_h */
