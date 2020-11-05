//
//  PEPIdentity+Internal.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 05.11.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPIdentity+Internal.h"

#import "pEpEngine.h"

@implementation PEPIdentity (Internal)

- (void)reset
{
    self.commType = PEP_ct_unknown;
    self.language = nil;
    self.fingerPrint = nil;
    self.userID = @"";
    self.userName = nil;
    self.isOwn = NO;
    self.flags = 0;
}

@end
