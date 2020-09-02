//
//  PEPIdentity+isPEPUser.h
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 20.08.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPIdentity+isPEPUser.h"

#import <PEPObjCAdapterFramework/PEPObjCAdapterFramework.h>

#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"

NS_ASSUME_NONNULL_BEGIN

@implementation PEPIdentity (isPEPUser)

- (NSNumber * _Nullable)isPEPUser:(PEPInternalSession * _Nullable)session
                            error:(NSError * _Nullable * _Nullable)error
{
    if (!session) {
        session = [PEPSessionProvider session];
    }
    return [session isPEPUser:self error:error];
}

@end

NS_ASSUME_NONNULL_END
