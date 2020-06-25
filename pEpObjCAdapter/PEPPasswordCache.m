//
//  PEPPasswordCache.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 25.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPasswordCache.h"

@implementation PEPPasswordCache

/// Internal constructor (for now).
- (instancetype)initTimeout:(NSUInteger)timeout
{
    self = [super init];
    if (self) {
        _timeout = timeout;
    }
    return self;
}

/// Public constructor with default values.
- (instancetype)init
{
    return [self initTimeout:10 * 60];
}

- (void)addPassword:(NSString *)password
{
}

- (NSArray *)passwords
{
    return @[];
}

@end
