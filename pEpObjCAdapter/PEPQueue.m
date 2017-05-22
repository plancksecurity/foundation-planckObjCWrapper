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

- (void)enqueue:(id)object
{
    [_cond lock];
    
    if (_queue)
        [_queue insertObject:object atIndex:0];
    
    [_cond signal];
    
    [_cond unlock];
    
}

- (id)timedDequeue:(time_t*)timeout
{
    id tmp = nil;
    
    [_cond lock];
    
    while (_queue && _queue.count == 0)
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


- (void)dealloc
{
    self.queue = nil;
    self.cond = nil;
}

@end
