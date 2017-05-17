//
//  NSArray+Extension.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 03.05.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation ArrayTake

- (instancetype)initWithElements:(NSArray * _Nonnull)elements rest:(NSArray * _Nonnull)rest
{
    if (self = [super init]) {
        _elements = elements;
        _rest = rest;
    }
    return self;
}

@end

@implementation NSArray (Extension)

- (ArrayTake * _Nullable)takeOrNil:(NSInteger)count
{
    if (self.count >= count) {
        NSInteger restCount = self.count - count;
        NSArray *elements = [self subarrayWithRange:NSMakeRange(0, count)];
        NSArray *rest = [self subarrayWithRange:NSMakeRange(count, restCount)];
        ArrayTake *taken = [[ArrayTake alloc] initWithElements:elements rest:rest];
        return taken;
    }
    return nil;
}

@end
