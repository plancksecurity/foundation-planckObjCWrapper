//
//  PEPTypesTestUtil.m
//  PEPObjCAdapterTypesTests_iOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPTypesTestUtil.h"

#import "PEPIdentity.h"

@implementation PEPTypesTestUtil

+ (PEPIdentity *)pEpIdentityWithAllFieldsFilled {
    PEPIdentity *identity = [PEPIdentity new];

    identity.address = @"test@host.com";
    identity.userID = @"pEp_own_userId";
    identity.fingerPrint = @"184C1DE2D4AB98A2A8BB7F23B0EC5F483B62E19D";
    identity.language = @"cat";
    identity.commType = PEPCommTypePEP;
    identity.isOwn = YES;
    identity.flags = PEPIdentityFlagsNotForSync;

    return identity;
}

@end
