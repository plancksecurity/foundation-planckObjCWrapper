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

/// Timeout of passwords in seconds.
@property (nonatomic) NSTimeInterval timeout;

@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) NSMutableArray<PEPPassphraseCacheEntry *> *mutablePassphraseEntries;
@property (nonatomic) dispatch_source_t timer;

@end

@implementation PEPPassphraseCache

static PEPPassphraseCache *s_sharedInstance;

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        s_sharedInstance = [[PEPPassphraseCache alloc] init];
    }
}

+ (instancetype)sharedInstance
{
    return s_sharedInstance;
}

/// Internal constructor (for now).
- (instancetype)initWithPassphraseTimeout:(NSTimeInterval)timeout
                      checkExpiryInterval:(NSTimeInterval)checkExpiryInterval
{
    self = [super init];
    if (self) {
        _timeout = timeout;
        _queue = dispatch_queue_create("PEPPassphraseCache Queue", DISPATCH_QUEUE_SERIAL);
        _mutablePassphraseEntries = [NSMutableArray arrayWithCapacity:s_maxNumberOfPassphrases];

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
        [self.mutablePassphraseEntries addObject:entry];
        if (self.mutablePassphraseEntries.count > s_maxNumberOfPassphrases) {
            [self.mutablePassphraseEntries removeObjectAtIndex:0];
        }

        [self sortPassphrases];
    });
}

- (NSArray<NSString *> *)passphrases
{
    NSMutableArray *resultingPassphrases = [NSMutableArray
                                            arrayWithCapacity:s_maxNumberOfPassphrases + 1];
    dispatch_sync(self.queue, ^{
        for (PEPPassphraseCacheEntry *entry in self.mutablePassphraseEntries) {
            if (![self isExpiredPassphraseEntry:entry]) {
                [resultingPassphrases addObject:entry.passphrase];
            }
        }
    });
    [resultingPassphrases insertObject:@"" atIndex:0];
    return [NSArray arrayWithArray:resultingPassphrases];
}

/// Remove password entries that have timed out.
/// - Note: Assumes it gets called on `queue`.
- (void)removeStaleEntries
{
    NSMutableArray *resultingPassphrases = [NSMutableArray
                                            arrayWithCapacity:s_maxNumberOfPassphrases];

    for (PEPPassphraseCacheEntry *entry in self.mutablePassphraseEntries) {
        if (![self isExpiredPassphraseEntry:entry]) {
            [resultingPassphrases addObject:entry];
        }
    }

    [self.mutablePassphraseEntries removeAllObjects];
    [self.mutablePassphraseEntries addObjectsFromArray:resultingPassphrases];
}

- (void)resetTimeoutForPassphrase:(NSString *)passphrase
{
    if ([passphrase isEqualToString:@""]) {
        // Ignore the empty passphrase, it's always there from the client's view,
        // but not contained in the internal model.
        return;
    }

    dispatch_sync(self.queue, ^{
        BOOL foundAtLeastOnce = NO;
        for (PEPPassphraseCacheEntry *entry in self.mutablePassphraseEntries) {
            if ([entry.passphrase isEqualToString:passphrase]) {
                foundAtLeastOnce = YES;
                entry.dateAdded = [NSDate date];
            }
        }

        if (foundAtLeastOnce) {
            [self sortPassphrases];
        }
    });
}

- (BOOL)isExpiredPassphraseEntry:(PEPPassphraseCacheEntry *)passphraseEntry
{
    NSDate *now = [NSDate date];
    NSDate *minimum = [now dateByAddingTimeInterval:-self.timeout];
    NSTimeInterval minimumTimeInterval = [minimum timeIntervalSinceReferenceDate];

    if ([passphraseEntry.dateAdded timeIntervalSinceReferenceDate] < minimumTimeInterval) {
        return YES;
    }

    return NO;
}

/// Sort the stored passphrases, last (successfully) used or added first.
/// Assumes being called from the internal queue.
- (void)sortPassphrases
{
    NSArray *sorted = [self sortedArrayByDateNewestFirst:self.mutablePassphraseEntries];
    [self.mutablePassphraseEntries
     replaceObjectsInRange:NSMakeRange(0, [self.mutablePassphraseEntries count])
     withObjectsFromArray:sorted];
}

- (NSArray<PEPPassphraseCacheEntry *> *)sortedArrayByDateNewestFirst:(NSArray<PEPPassphraseCacheEntry *> *)array
{
    return [array sortedArrayUsingComparator:^NSComparisonResult(PEPPassphraseCacheEntry *entry1,
                                                                 PEPPassphraseCacheEntry *entry2) {
        NSTimeInterval interval1 = [entry1.dateAdded timeIntervalSinceReferenceDate];
        NSTimeInterval interval2 = [entry2.dateAdded timeIntervalSinceReferenceDate];

        if (interval1 > interval2) {
            return NSOrderedAscending;
        } else if (interval1 < interval2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

@end
