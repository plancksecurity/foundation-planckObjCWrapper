//
//  PEPSession+SetIdentity.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 14.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPSession+SetIdentity.h"

#import "PEPSessionProvider.h"
#import "PEPInternalSession+SetIdentity.h"
#import "PEPEngineTypes.h"
#import "PEPIdentity.h"
#import "PEPSession+Internal.h"

@implementation PEPSession (SetIdentity)

- (void)setIdentity:(PEPIdentity *)identity
      errorCallback:(void (^)(NSError *error))errorCallback
    successCallback:(void (^)(void))successCallback
{
    __block PEPIdentity *theIdentity = [[PEPIdentity alloc] initWithIdentity:identity];

    dispatch_async([self queue], ^{
        NSError *error = nil;
        BOOL success = [[PEPSessionProvider session] setIdentity:theIdentity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

@end
