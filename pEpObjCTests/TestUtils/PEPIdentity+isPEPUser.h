//
//  PEPIdentity+isPEPUser.h
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 20.08.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <PEPObjCAdapterFramework/PEPObjCAdapterFramework.h>

NS_ASSUME_NONNULL_BEGIN

@class PEPInternalSession;
@class PEPIdentity;

@interface PEPIdentity (isPEPUser)

- (NSNumber * _Nullable)isPEPUser:(PEPInternalSession * _Nullable)session
                            error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
