//
//  PEPLock.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Provides global locking to all (write) use of pEp sessions.
 */
@interface PEPLock : NSObject

/**
 Locks for (potential) sqlite writes.
 */
+ (void)lockWrite;

/**
 Unlocks (potential) sqlite writes.
 */
+ (void)unlockWrite;

@end
