//
//  PEPGroup+Engine.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPGroup+Engine.h"

#import "PEPIdentity+Engine.h"
#import "NSArray+MemberList.h"

@implementation PEPGroup (Engine)

- (pEp_group *)toStruct
{
    pEp_identity *identityStruct = [self.identity toStruct];
    pEp_identity *managerStruct = [self.identity toStruct];
    member_list *memberListStruct = [self.members toMemberList];

    pEp_group *group = new_group(identityStruct, managerStruct, memberListStruct);

    return group;
}

@end
