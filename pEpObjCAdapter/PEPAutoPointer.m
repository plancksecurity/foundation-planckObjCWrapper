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

- (instancetype)initWithPointer:(void *)pointer freeFn:(void (*)(void *))freeFn
{
    self = [super init];
    if (self) {
        _thePointer = pointer;
        _freeFn = freeFn;
    }
    return self;
}

- (instancetype)initWithMessage:(message *)message
{
    return [self initWithPointer:message freeFn:(void (*)(void *)) free_message];
}

- (instancetype)init
{
    return [self initWithPointer:nil freeFn:free];
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
