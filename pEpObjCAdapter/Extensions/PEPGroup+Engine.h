//
//  PEPGroup+Engine.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "group.h"

#import "PEPGroup.h"

NS_ASSUME_NONNULL_BEGIN

@class PEPMember;

@interface PEPGroup (Engine)

/// Convert into an engine struct.
/// The caller is responsible for freeing, via `free_group`.
- (pEp_group *)toStruct;

@end

NS_ASSUME_NONNULL_END
