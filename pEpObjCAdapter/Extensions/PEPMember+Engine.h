//
//  PEPMember+Engine.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "group.h"

#import "PEPMember.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPMember (Engine)

+ (instancetype)fromStruct:(pEp_member * _Nonnull)memberStruct;

/// Convert into an engine struct.
/// The caller is responsible for freeing, via `free_member`.
- (pEp_member *)toStruct;

@end

NS_ASSUME_NONNULL_END
