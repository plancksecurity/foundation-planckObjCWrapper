//
//  PEPInternalSession+SetIdentity.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 14.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPInternalSession+SetIdentity.h"

#import "PEPTypes.h"
#import "PEPInternalSession.h"
#import "PEPInternalSession+PassphraseCache.h"
#import "NSError+PEP+Internal.h"
#import "PEPIdentity+Engine.h"

#import "pEpEngine.h"

@implementation PEPInternalSession (SetIdentity)

- (BOOL)setIdentity:(PEPIdentity *)identity error:(NSError * _Nullable * _Nullable)error
{
    pEp_identity *ident = [identity toStruct];

    PEPStatus status = (PEPStatus) [self runWithPasswords:^PEP_STATUS(PEP_SESSION session) {
        return set_identity(self.session, ident);
    }];

    if ([NSError setError:error fromPEPStatus:status]) {
        free_identity(ident);
        return NO;
    }

    free_identity(ident);

    return YES;
}

@end
