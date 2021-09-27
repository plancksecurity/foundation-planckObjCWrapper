//
//  PEPAttachment.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 16.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

// typedef NS_CLOSED_ENUM(int, PEPDecryptFlags) {
//     PEPDecryptFlagsNone = 0x0, // not actually defined in the engine
//     PEPDecryptFlagsOwnPrivateKey = 0x1, // PEP_decrypt_flag_own_private_key
//     PEPDecryptFlagsConsume = 0x2, //PEP_decrypt_flag_consume
//     PEPDecryptFlagsIgnore = 0x4, // PEP_decrypt_flag_ignore
//     PEPDecryptFlagsSourceModified = 0x8, // PEP_decrypt_flag_src_modified
//     PEPDecryptFlagsUntrustedServer = 0x100, // PEP_decrypt_flag_untrusted_server
//     PEPDecryptFlagsDontTriggerSync = 0x200, // PEP_decrypt_flag_dont_trigger_sync
// };

// /// Possible errors from adapter without involvement from the engine.
// typedef NS_CLOSED_ENUM(NSInteger, PEPAdapterError) {
//     /// Passwords are limited in size, and this error indicates a password that contains
//     /// too many codepoints.
//     PEPAdapterErrorPassphraseTooLong = 0
// };

typedef NS_CLOSED_ENUM(int, PEPContentDisposition) {
    PEPContentDispositionAttachment = 0, // PEP_CONTENT_DISP_ATTACHMENT
    PEPContentDispositionInline = 1, // PEP_CONTENT_DISP_INLINE
    PEPContentDispositionOther = -1 // PEP_CONTENT_DISP_OTHER
};

@interface PEPTEST : NSObject

@property (nonatomic, nonnull) NSData *data;
@property (nonatomic) NSInteger size;
@property (nonatomic, nullable) NSString *mimeType;
@property (nonatomic, nullable) NSString *filename;
@property (nonatomic) PEPContentDisposition contentDisposition;

- (_Nonnull instancetype)initWithData:(NSData * _Nonnull)data;

@end
