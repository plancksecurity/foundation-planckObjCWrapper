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
/// for pointers that are not aware of it, e.g. allocated by malloc.
///
/// When this object goes out of scope (is released), it calls `free()` or a configurable function on the managed pointer.
@interface PEPAutoPointer : NSObject

/// The function that will be used to free the managed pointer, `free` by default.
@property (nonatomic) void (* freeFn)(void *);

/// Specialized version that will auto-release/free the given message struct when it goes out of scope.
+ (instancetype)autoPointerWithMessage:(message *)message;

/// Construct an object containing a pointer, and invoke the freeing function when the object,
/// and therefore the pointer, goes out of scope.
/// @param pointer The pointer to free when going out of scope.
/// @param freeFn The function to use for freeing the pointer.
- (instancetype)initWithPointer:(void *)pointer freeFn:(void (*)(void *))freeFn;

/// Constructs an object containing nil as a pointer, and using `free()` as the method to free it.
/// In order to be useful, the pointer needs to be filled after that. See `voidPointerPointer` or `charPointerPointer`.
- (instancetype)init;

/// Specialized version that will auto-release/free the given message struct when it goes out of scope.
- (instancetype)initWithMessage:(message *)message;

/// Provide this to a function that expects a `void **` pointer to allocate and fill.
- (void **)voidPointerPointer;

/// Provide this to a function that expects a `char **` pointer to allocate and fill.
- (char **)charPointerPointer;

/// Access the managed pointer as a void pointer.
- (void *)voidPointer;

/// Access the managed pointer as a char pointer.
- (char *)charPointer;

@end
