//
//  PEPDecryptFlags.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 18.11.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#ifndef PEPDecryptFlags_h
#define PEPDecryptFlags_h

typedef NS_CLOSED_ENUM(int, PEPDecryptFlags) {
    PEPDecryptFlagsNone = 0x0, // not actually defined in the engine
    PEPDecryptFlagsOwnPrivateKey = 0x1, // PEP_decrypt_flag_own_private_key
    PEPDecryptFlagsConsume = 0x2, //PEP_decrypt_flag_consume
    PEPDecryptFlagsIgnore = 0x4, // PEP_decrypt_flag_ignore
    PEPDecryptFlagsSourceModified = 0x8, // PEP_decrypt_flag_src_modified
    PEPDecryptFlagsUntrustedServer = 0x100, // PEP_decrypt_flag_untrusted_server
    PEPDecryptFlagsDontTriggerSync = 0x200, // PEP_decrypt_flag_dont_trigger_sync
};

#endif /* PEPDecryptFlags_h */
