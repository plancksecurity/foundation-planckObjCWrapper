//
//  NSArray+MemberList.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPMember+Engine.h"

#import "NSArray+MemberList.h"

@implementation NSArray (MemberList)

+ (instancetype)fromMemberList:(member_list *)memberList
{
    if (memberList == nil) {
        return @[];
    }

    NSMutableArray *array = [NSMutableArray array];

    for (member_list *theMemberList = memberList;
         theMemberList;
         theMemberList = theMemberList->next) {
        PEPMember *member = [PEPMember fromStruct:theMemberList->member];
        [array addObject:member];
    }

    return [NSArray arrayWithArray:array];
}

@end
