//
//  PEPQueue.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 15.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "PEPQueue.h"

@implementation PEPQueue

- (void)queue:(id)object
{
    @synchronized(self) {
        [self insertObject:object atIndex:0];
    }
}

- (id)dequeue
{
    @synchronized(self) {
        id object = [[self lastObject] copy];
        [self removeLastObject];
        return object;
    }
}

@end
