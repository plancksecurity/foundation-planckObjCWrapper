//
//  PEPGroup+Engine.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPGroup+Convert.h"

#import "PEPIdentity+PEPConvert.h"
#import "NSArray+MemberList.h"

@implementation PEPGroup (Engine)

+ (instancetype)fromStruct:(pEp_group * _Nonnull)groupStruct
{
    PEPIdentity *groupIdentity = [PEPIdentity fromStruct:groupStruct->group_identity];
    PEPIdentity *managerIdentity = [PEPIdentity fromStruct:groupStruct->manager];
    NSArray<PEPMember *> *members = [NSArray fromMemberList:groupStruct->members];
    BOOL active = groupStruct->active;

    return [[PEPGroup alloc] initWithIdentity:groupIdentity
                                      manager:managerIdentity
                                      members:members
                                       active:active];
}

@end
