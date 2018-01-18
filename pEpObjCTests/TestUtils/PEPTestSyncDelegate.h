//
//  PEPTestSyncDelegate.h
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 18.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPObjCAdapter.h"

@interface PEPTestSyncDelegate : NSObject<PEPSyncDelegate>

- (BOOL)waitUntilSent:(time_t)maxSec;

@property (nonatomic) bool sendWasCalled;
@property (nonatomic, strong) NSCondition *cond;

@end

