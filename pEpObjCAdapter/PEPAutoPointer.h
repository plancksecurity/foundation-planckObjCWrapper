//
//  PEPAutoPointer.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 11.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Implements a very basic method to enable use of ARC (or manual cocoa memory management)
 for malloc-created pointers.

 When this object goes out of scope (is freed), it calls free() on the contained pointer.
 */
@interface PEPAutoPointer : NSObject

/// The function that will be used to free the pointer, `free` by default.
@property (nonatomic) void (* freeFn)(void *);

/**
 Provide this to a C-function that expects a `void **` pointer to allocate and fill.
 */
- (void **)voidPointerPointer;

/**
 Provide this to a C-function that expects a `char **` pointer to allocate and fill.
 */
- (char **)charPointerPointer;

/**
 When you have used some C-function to receive content,
 use this to access it as a `void *` pointer.
 */
- (void *)voidPointer;

/**
 When you have used some C-function to receive content,
 use this to access it as a `char *` pointer.
 */
- (char *)charPointer;

@end
