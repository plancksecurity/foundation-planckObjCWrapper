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

@end

NS_ASSUME_NONNULL_END
