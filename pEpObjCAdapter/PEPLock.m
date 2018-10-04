//
//  PEPLock.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPLock.h"

static NSLock *s_writeLock;

@implementation PEPLock

+ (void)initialize
{
    s_writeLock = [[NSLock alloc] init];
}

+ (void)lockWrite
{
    [s_writeLock lock];
}

+ (void)unlockWrite
{
    [s_writeLock unlock];
}

@end
