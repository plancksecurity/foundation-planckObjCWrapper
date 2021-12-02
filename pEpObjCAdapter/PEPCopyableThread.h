//
//  PEPCopyableThread.h
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 06.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PEPCopyableThread;

/**
 Wrapper around NSThread. Created solely to be able to use a thread as key in
 a NSDIctionary (e.g. conform to NSCopying).
 */
@interface PEPCopyableThread : NSObject<NSCopying>

@property (atomic, strong, readonly) NSThread * _Nullable thread;

- (instancetype _Nonnull )initWithThread:(NSThread * _Nonnull)thread;

/**
 A Boolean value that indicates whether the receiver has finished execution.
 @return YES if the receiver has finished execution, otherwise NO.
 */
- (BOOL)isFinished;

/**
 Changes the cancelled state of the receiver to indicate that it should exit.
 */
- (void)cancel;

@end
