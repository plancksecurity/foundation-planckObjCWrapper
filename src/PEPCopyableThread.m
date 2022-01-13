//
//  PEPCopyableThread.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 06.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPCopyableThread.h"

@interface PEPCopyableThread()
@property (atomic, strong) NSThread *thread;
@end

@implementation PEPCopyableThread

- (BOOL)isFinished
{
    return self.thread.isFinished || !self.thread;
}

- (void)cancel
{
    [self.thread cancel];
}

#pragma mark - Life Cycle

- (instancetype)init
{
    NSAssert(false, @"Please call initWithThread instead");
    return nil;
}

- (instancetype)initWithThread:(NSThread * _Nonnull)thread;
{
    self = [super init];
    if (self) {
        self.thread = thread;
    }
    return self;
}

- (void)dealloc
{
    self.thread = nil;
}

#pragma mark - NSObject

- (BOOL)isEqual:(PEPCopyableThread *)object
{
    return [self.thread isEqual:object.thread];
}

- (NSUInteger)hash
{
    // Cast is required to fix GNUStep error: " error: property 'hash' not found on object of type 'id'"
    // Assume GNUstep translates ìnstancetype` to `id`.
    return ((NSString *) [NSString stringWithFormat:@"%@", self.thread]).hash;
}

- (NSString *)description
{
    return [self.thread description];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    PEPCopyableThread *copy = [[PEPCopyableThread alloc] initWithThread:self.thread];
    return copy;
}

@end
