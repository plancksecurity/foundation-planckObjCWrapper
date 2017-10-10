//
//  PEPInvocationArgumentWrapper.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 10.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPInvocationArgumentWrapper.h"

@interface PEPInvocationArgumentWrapper()
@property id value;
@property PEPInvocationArgumentWrapperType type;
@end

@implementation PEPInvocationArgumentWrapper

#pragma mark - Public API

+ (instancetype)instanceWithInteger:(NSInteger)value
{
    return [[self alloc] initWithInteger:value];
}

+ (instancetype)instanceWithObject:(id)value
{
    return [[self alloc] initWithObject:value];
}

#pragma mark - Life Cycle

- (instancetype)initWithInteger:(NSInteger)value
{
    return [self initWithValue:[NSNumber numberWithInteger:value] type:typeObject];
}

- (instancetype)initWithObject:(id)value
{
    return [self initWithValue:value type:typeObject];
}

- (instancetype)initWithValue:(id)value type:(PEPInvocationArgumentWrapperType)type
{
    self = [super init];
    if (self) {
        self.value = value;
        self.type = type;
    }
    return self;
}

@end
