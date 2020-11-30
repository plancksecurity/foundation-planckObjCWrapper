//
//  PEPIdentity+Engine.h
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "pEpEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity (Engine)

/// @Note: If the ident does not contain an address, no PEPIdentity can be constructed.
+ (instancetype _Nullable)fromStruct:(pEp_identity * _Nonnull)identityStruct;

- (pEp_identity *)toStruct;
- (void)overWriteFromStruct:(pEp_identity * _Nonnull)identityStruct;

@end

NS_ASSUME_NONNULL_END
