//
//  PEPCopyableThread.h
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 06.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Wrapper around NSThread. Created solely to be able to use a thread as key in
 a NSDIctionary (e.g. conform to NSCopying).
 */
@interface PEPCopyableThread : NSObject<NSCopying>

@property (atomic, strong, readonly) NSThread *thread;

- (instancetype)initWithThread:(NSThread * _Nonnull)thread;

@end
