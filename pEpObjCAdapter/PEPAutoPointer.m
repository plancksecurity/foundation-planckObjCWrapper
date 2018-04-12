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
