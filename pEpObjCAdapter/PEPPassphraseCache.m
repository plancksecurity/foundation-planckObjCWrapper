//
//  PEPPassphraseCache.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 25.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseCache.h"

#import "PEPPassphraseCacheInternal.h"

#import "PEPPassphraseCacheEntry.h"

static NSUInteger s_maxNumberOfPassphrases = 20;
static NSTimeInterval s_defaultTimeoutInSeconds = 10 * 60;
static NSTimeInterval s_defaultCheckExpiryInterval = 60;

@interface PEPPassphraseCache ()

@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) NSMutableArray<PEPPassphraseCacheEntry *> *mutablePassphrases;
@property (nonatomic) dispatch_source_t timer;

@end

@implementation PEPPassphraseCache

/// Internal constructor (for now).
- (instancetype)initWithPassphraseTimeout:(NSTimeInterval)timeout
                      checkExpiryInterval:(NSTimeInterval)checkExpiryInterval
{
    self = [super init];
    if (self) {
        _timeout = timeout;
        _queue = dispatch_queue_create("PEPPassphraseCache Queue", DISPATCH_QUEUE_SERIAL);
        _mutablePassphrases = [NSMutableArray arrayWithCapacity:s_maxNumberOfPassphrases];

        // we have a strong reference to the timer, but the timer doesn't have one to us
        typeof(self) __weak weakSelf = self;

        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
        dispatch_source_set_timer(_timer,
                                  DISPATCH_TIME_NOW,
                                  checkExpiryInterval * NSEC_PER_SEC,
                                  checkExpiryInterval / 10 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
            [weakSelf removeStaleEntries];
        });
        dispatch_resume(_timer);
    }
    return self;
}

/// Public constructor with default values.
- (instancetype)init
{
    return [self initWithPassphraseTimeout:s_defaultTimeoutInSeconds
                       checkExpiryInterval:s_defaultCheckExpiryInterval];
}

- (void)addPassphrase:(NSString *)passphrase
{
    PEPPassphraseCacheEntry *entry = [[PEPPassphraseCacheEntry alloc]
                                      initWithPassphrase:passphrase];
    dispatch_sync(self.queue, ^{
        [self.mutablePassphrases addObject:entry];
        if (self.mutablePassphrases.count > s_maxNumberOfPassphrases) {
            [self.mutablePassphrases removeObjectAtIndex:0];
        }
    });
}

- (NSArray *)passphrases
{
    NSMutableArray *resultingPassphrases = [NSMutableArray
                                            arrayWithCapacity:s_maxNumberOfPassphrases + 1];
    [resultingPassphrases addObject:@""];
    dispatch_sync(self.queue, ^{
        for (PEPPassphraseCacheEntry *entry in self.mutablePassphrases) {
            [resultingPassphrases addObject:entry.passphrase];
        }
    });
    return [NSArray arrayWithArray:resultingPassphrases];
}

/// Remove password entries that have timed out.
- (void)removeStaleEntries
{
    NSDate *now = [NSDate date];
    NSDate *minimum = [now dateByAddingTimeInterval:-s_defaultTimeoutInSeconds];
    NSTimeInterval minimumTimeInterval = [minimum timeIntervalSinceReferenceDate];
    dispatch_sync(self.queue, ^{
        NSMutableArray *resultingPassphrases = [NSMutableArray
                                                arrayWithCapacity:s_maxNumberOfPassphrases];

        for (PEPPassphraseCacheEntry *entry in self.mutablePassphrases) {
            if ([entry.dateAdded timeIntervalSinceReferenceDate] >= minimumTimeInterval) {
                [resultingPassphrases addObject:entry];
            }
        }

        [self.mutablePassphrases removeAllObjects];
        [self.mutablePassphrases addObjectsFromArray:resultingPassphrases];
    });
}

@end
