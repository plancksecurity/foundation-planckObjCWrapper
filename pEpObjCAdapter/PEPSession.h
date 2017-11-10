//
//  PEPSession.h
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 11.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPSessionProtocol.h"
#import "PEPMessageUtil.h"

/**
 Fake session to handle to the client.

 Assures all calls are handled on the correct internal session for the thread it is called on.
 You can instatntiate and use this session how often and wherever you want. Also over multiple threads.

 Note: You must call `cleanup()` once before your process gets terminated to be able to gracefully shutdown.
 It is the clients responsibility not to make any calls to PEPSession in between the last call
 to `cleanup()` and getting terminated.
 */
@interface PEPSession : NSObject <PEPSessionProtocol>

/**
 You must call this method once before your process gets terminated to be able to gracefully shutdown.
 You must not make any calls to PEPSession in between the last call to `cleanup()` and getting terminated.

 Only for performance reasons: call this method only if you have to.
 */
+ (void)cleanup;

@end
