//
//  PEPQueue.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 15.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "PEPQueue.h"


@interface PEPQueue ()

@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, strong) NSCondition *cond;

@end

@implementation PEPQueue

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.queue = [[NSMutableArray alloc] init];
        self.cond = [[NSCondition alloc] init];
    }
    
    return self;
}

/// A block that gets called to modify the queue model.
typedef void (^queueOp)(NSMutableArray *queue);

/// Lock the queue and calls the given block.
/// @param block The block to invoke once the queue is locked.
- (void)lockQueueAndUpdateWithBlock:(queueOp)block
{
    [_cond lock];

    if (_queue) {
        block(_queue);
    }

    [_cond signal];
    [_cond unlock];
}

- (void)enqueue:(id)object
{
    [self lockQueueAndUpdateWithBlock:^(NSMutableArray *queue){
        [queue insertObject:object atIndex:0];
    }];
}

- (void)prequeue:(id)object
{
    [self lockQueueAndUpdateWithBlock:^(NSMutableArray *queue){
        [queue addObject:object];
    }];
}

- (id)timedDequeue:(time_t*)timeout
{
    id tmp = nil;
    
    [_cond lock];
    
    if (_queue && _queue.count == 0)
    {
        if (*timeout == 0)
        {
            [_cond wait];
        }
        else
        {
            NSDate *end = [NSDate dateWithTimeIntervalSinceNow: *timeout];
            
            [_cond waitUntilDate:end];
            
            NSTimeInterval remaining = [end timeIntervalSinceNow];
            
            if (remaining > 0)
                *timeout = remaining;
            else
                *timeout = 0;
        }
    }
    
    if (_queue)
    {
        tmp = [_queue lastObject];
        
        [_queue removeLastObject];
    }

    [_cond unlock];

    return tmp;
}

- (id)dequeue
{
    time_t zeroTimeout = 0;
    return [self timedDequeue:&zeroTimeout];
}

- (void)kill
{
    [_cond lock];

    _queue = nil;
    
    [_cond signal];
    [_cond unlock];

}

- (void)purge:(deleteOp)del
{
    [_cond lock];

    id item;
    for (item in _queue)
    {
        del(item);
    }
    _queue = nil;
    
    [_cond signal];
    [_cond unlock];
}

- (void)removeAllObjects
{
    [_cond lock];

    [self.queue removeAllObjects];

    [_cond signal];
    [_cond unlock];
}


- (void)dealloc
{
    self.queue = nil;
    self.cond = nil;
}

@end
