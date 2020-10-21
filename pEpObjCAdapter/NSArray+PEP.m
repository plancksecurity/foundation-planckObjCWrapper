//
//  NSArray+PEP.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSArray+PEP.h"

@implementation NSArray (PEP)

+ (NSArray * _Nonnull)arrayFromStringlist:(stringlist_t * _Nonnull)stringList
{
    NSMutableArray *array = [NSMutableArray array];

    for (stringlist_t *_sl = stringList; _sl && _sl->value; _sl = _sl->next) {
        [array addObject:[NSString stringWithUTF8String:_sl->value]];
    }

    return array;
}

- (stringlist_t * _Nullable)toStringList
{
    stringlist_t *sl = new_stringlist(NULL);
    if (!sl)
        return NULL;

    stringlist_t *_sl = sl;
    for (NSString *str in self) {
        _sl = stringlist_add(_sl, [[str precomposedStringWithCanonicalMapping] UTF8String]);
    }

    return sl;
}

@end
