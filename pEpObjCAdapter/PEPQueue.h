//
//  PEPQueue.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 15.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^deleteOp)(id);

/// FiFo queue.
@interface PEPQueue : NSObject

/// Puts an object into the queue (FiFo, first in, first out, so that the objects
/// that were put in before are dequeued before this one).
/// @param object The object to put into the queue.
- (void)enqueue:(id)object;

- (id)timedDequeue:(time_t*)timeout;

- (id)dequeue;

- (void)kill;

- (void)purge:(deleteOp)del;

/**
 Removes all objects from the queue.
 */
- (void)removeAllObjects;

@end
