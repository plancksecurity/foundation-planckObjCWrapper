//
//  PEPInternalSession+SetIdentity.h
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 14.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPInternalSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPInternalSession (SetIdentity)

/// Wraps the (internal) set_identity.
- (BOOL)setIdentity:(PEPIdentity *)identity error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
