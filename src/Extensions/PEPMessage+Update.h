//
//  PEPMessage+Update.h
//  PEPObjCTypeUtils_iOS
//
//  Created by Dirk Zimmermann on 8/8/23.
//

#import <Foundation/Foundation.h>

@import PEPObjCTypes;

NS_ASSUME_NONNULL_BEGIN

@interface PEPMessage (Update)

/// Update all identities that compose this message object, ultimately calling `update_identity` or `myself`.
///
/// @note Best effort, no errors are indicated.
- (void)updateIdentities;

@end

NS_ASSUME_NONNULL_END
