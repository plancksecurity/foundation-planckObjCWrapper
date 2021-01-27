//
//  PEPIdentityMock.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 26/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPIdentityMock.h"

@implementation PEPIdentityMock

- (instancetype)init {
    if (self = [super init]) {
        self.address = @"test@host.com";
        self.userID = @"pEp_own_userId";
        self.fingerPrint = @"184C1DE2D4AB98A2A8BB7F23B0EC5F483B62E19D";
        self.language = @"cat";
        self.commType = PEPCommTypePEP;
        self.isOwn = YES;
        self.flags = PEPIdentityFlagsNotForSync;
    }

    return  self;
}

@end
