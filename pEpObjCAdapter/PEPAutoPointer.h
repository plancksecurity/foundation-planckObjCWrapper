//
//  PEPAutoPointer.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 11.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "message.h"

/// Implements a basic method to enable automated reference counting (ARC)
/// for pointers that are not aware of it, e.g. allocatey by malloc.
///
/// When this object goes out of scope (is freed), it calls free() on the contained pointer.
@interface PEPAutoPointer : NSObject

/// The function that will be used to free the pointer, `free` by default.
@property (nonatomic) void (* freeFn)(void *);

/// Specialized version that can deal with the engine's message struct.
+ (instancetype)autoPointerWithMessage:(message *)message;

/// Specialized version that can deal with the engine's message struct.
- (instancetype)initWithMessage:(message *)message;

/// Provide this to a function that expects a `void **` pointer to allocate and fill.
- (void **)voidPointerPointer;

/// Provide this to a function that expects a `char **` pointer to allocate and fill.
- (char **)charPointerPointer;

/// Access the internal pointer as a void pointer.
- (void *)voidPointer;

/// Access the internal pointer as a char pointer.
- (char *)charPointer;

@end
