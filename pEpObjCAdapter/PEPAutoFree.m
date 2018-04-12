//
//  PEPAutoFree.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 11.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPAutoFree.h"

@interface PEPAutoFree ()

@property (nonatomic) void *thePointer;

@end

@implementation PEPAutoFree

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
    free(_thePointer);
}

@end
