//
//  PEPPassphraseCache.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 25.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseCache.h"

static NSUInteger s_numberOfPassphrases = 20;

@interface PEPPassphraseCache ()

@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) NSMutableArray *mutablePassphrases;

@end

@implementation PEPPassphraseCache

/// Internal constructor (for now).
- (instancetype)initTimeout:(NSUInteger)timeout
{
    self = [super init];
    if (self) {
        _timeout = timeout;
        _queue = dispatch_queue_create("PEPPassphraseCache Queue", DISPATCH_QUEUE_SERIAL);
        _mutablePassphrases = [NSMutableArray arrayWithCapacity:s_numberOfPassphrases];
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
    dispatch_sync(self.queue, ^{
        [self.mutablePassphrases addObject:passphrase];
        if (self.mutablePassphrases.count > s_numberOfPassphrases) {
            [self.mutablePassphrases removeObjectAtIndex:0];
        }
    });
}

- (NSArray *)passphrases
{
    NSMutableArray *resultingPassphrases = [NSMutableArray
                                            arrayWithCapacity:s_numberOfPassphrases + 1];
    [resultingPassphrases addObject:@""];
    dispatch_sync(self.queue, ^{
        for (NSString *passphrase in self.mutablePassphrases) {
            [resultingPassphrases addObject:passphrase];
        }
    });
    return [NSArray arrayWithArray:resultingPassphrases];
}

@end
