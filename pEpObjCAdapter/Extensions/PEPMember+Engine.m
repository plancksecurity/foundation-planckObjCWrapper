//
//  PEPMember+Engine.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPIdentity+Engine.h"

#import "pEpEngine.h"

#import "PEPMember+Engine.h"

@implementation PEPMember (Engine)

+ (instancetype)fromStruct:(pEp_member * _Nonnull)memberStruct
{
    PEPIdentity *ident = [PEPIdentity fromStruct:memberStruct->ident];
    BOOL joined = memberStruct->joined;
    return [[PEPMember alloc] initWithIdentity:ident joined:joined];
}

@end
