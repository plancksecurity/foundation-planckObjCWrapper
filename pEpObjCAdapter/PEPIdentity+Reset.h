//
//  PEPIdentity+PEPIdentity_Reset.h
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 23.07.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#import <PEPObjCAdapterFramework/PEPObjCAdapterFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity (Reset)

/**
 Puts all properties into a default/nil state.
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
