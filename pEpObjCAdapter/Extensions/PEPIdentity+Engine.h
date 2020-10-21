//
//  PEPIdentity+Engine.h
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPIdentity.h"

#import "pEpEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity (Engine)

- (pEp_identity *)toStruct;

@end

NS_ASSUME_NONNULL_END
