//
//  NSArray+MemberList.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "group.h"

NS_ASSUME_NONNULL_BEGIN

@class PEPMember;

@interface NSArray (MemberList)

+ (instancetype)fromMemberList:(member_list *)memberList;

@end

NS_ASSUME_NONNULL_END