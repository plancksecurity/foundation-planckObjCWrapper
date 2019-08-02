//
//  PEPIdentity+Internal.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 01.08.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#import "pEpEngine.h"

#import "PEPIdentity.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity (Internal)

/**
 Internal access to identity flags. Are only set by:
 * [PEPSessionProtocol mySelf:error].
 * [PEPSessionProtocol updateIdentity:error]
 */
@property (nonatomic) identity_flags_t flags;

@end

NS_ASSUME_NONNULL_END
