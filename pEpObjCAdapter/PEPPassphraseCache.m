//
//  PEPPassphraseCache.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 25.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseCache.h"

@interface PEPPassphraseCache ()

@property (nonatomic) dispatch_queue_t queue;

@end

@implementation PEPPassphraseCache

/// Internal constructor (for now).
- (instancetype)initTimeout:(NSUInteger)timeout
{
    self = [super init];
    if (self) {
        _timeout = timeout;
        _queue = dispatch_queue_create("PEPPassphraseCache Queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

/// Public constructor with default values.
- (instancetype)init
{
    return [self initTimeout:10 * 60];
}

- (void)addPassphrase:(NSString *)passphrase
{
}

- (NSArray *)passphrases
{
    return @[];
}

@end
