//
//  PEPAutoPointer.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 11.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPAutoPointer.h"

@interface PEPAutoPointer ()

@property (nonatomic) void *thePointer;

@end

@implementation PEPAutoPointer

+ (instancetype)autoPointerWithMessage:(message *)message
{
    return [[self alloc] initWithMessage:message];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // By default, use free() for releasing the internal pointer
        self.freeFn = free;
    }
    return self;
}

- (instancetype)initWithMessage:(message *)message
{
    self = [self init];
    if (self) {
        _thePointer = message;
        // For freeing a message, free_message() is needed
        _freeFn = (void (*)(void *)) free_message;
    }
    return self;
}

- (void **)voidPointerPointer
{
    return &_thePointer;
}

- (char **)charPointerPointer
{
    return (char **) self.voidPointerPointer;
}

- (void *)voidPointer
{
    return self.thePointer;
}

- (char *)charPointer
{
    return (char *) self.voidPointer;
}

- (void)dealloc
{
    if (_thePointer) {
        self.freeFn(_thePointer);
    }
}

@end
