//
//  PEPSession+Internal.h
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 14.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPSession (Internal)

+ (dispatch_queue_t)queue;

@end

NS_ASSUME_NONNULL_END
