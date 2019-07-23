//
//  PEPIdentity+PEPIdentity_Reset.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 23.07.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#import "PEPIdentity+Reset.h"

#import "pEpEngine.h"

@implementation PEPIdentity (Reset)

- (void)reset
{
    self.commType = PEP_ct_unknown;
    self.language = nil;
    self.fingerPrint = nil;
    self.userName = nil;
    self.isOwn = NO;
}

@end
