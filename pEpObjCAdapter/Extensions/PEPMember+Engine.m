//
//  PEPMember+Engine.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "pEpEngine.h"

#import "PEPIdentity+Engine.h"

#import "PEPMember+Engine.h"

@implementation PEPMember (Engine)

- (pEp_member *)toStruct
{
    pEp_identity *ident = [self.identity toStruct];
    return new_member(ident);
}

@end
