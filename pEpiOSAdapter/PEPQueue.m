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

- (id)dequeue
{
    id tmp = nil;
    
    [_cond lock];
    
    while (_queue && _queue.count == 0)
    {
        [_cond wait];
    }
    
    if (_queue)
    {
        tmp = [_queue lastObject];
        
        [_queue removeLastObject];
    }
    
    [_cond unlock];
    
    return tmp;
}

- (void)kill
{
    [_cond lock];
    
    _queue = nil;
    
    [_cond signal];
    
    [_cond unlock];
}

- (NSUInteger)count
{
    return [_queue count];
}

- (void)dealloc
{
    self.queue = nil;
    self.cond = nil;
}

@end