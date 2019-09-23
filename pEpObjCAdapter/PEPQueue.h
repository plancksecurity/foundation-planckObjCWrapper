//
//  PEPQueue.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 15.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^deleteOp)(id);

@interface PEPQueue : NSObject

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
