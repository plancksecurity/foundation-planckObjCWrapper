//
//  PEPPassphraseCacheEntry.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 26.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseCacheEntry.h"

static NSTimeInterval s_defaultTimeoutInSeconds = 10 * 60;

@implementation PEPPassphraseCacheEntry

- (instancetype)initWithPassphrase:(NSString *)passphrase
{
    self = [super init];
    if (self) {
        self.passphrase = passphrase;
        self.dateAdded = [NSDate date];
    }
    return self;
}

- (BOOL)isExpired
{
    return NO;
}

@end
