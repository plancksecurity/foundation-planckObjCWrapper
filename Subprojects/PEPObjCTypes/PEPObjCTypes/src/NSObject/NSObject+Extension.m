//
//  NSObject+Extension.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 24.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSObject (Extension)

+ (BOOL)isEqualObject1:(id _Nullable)obj1 toObject2:(id _Nullable)obj2
{
    if (obj1 != nil) {
        return [obj1 isEqual:obj2];
    } else if (obj2 != nil) {
        return [obj2 isEqual:obj1];
    }

    // both must be nil
    return YES;
}

+ (BOOL)isEqualString1:(NSString * _Nullable)str1 toString2:(NSString * _Nullable)str2
{
    if (str1 != nil) {
        return [str1 isEqualToString:str2];
    } else if (str2 != nil) {
        return [str2 isEqual:str1];
    }

    // both must be nil
    return YES;
}

- (BOOL)isEqualToObject:(NSObject * _Nonnull)other
            basedOnKeys:(NSArray<NSString *> * _Nonnull)keys
{
    for (NSString *theKey in keys) {
        NSObject *objSelf = [self valueForKey:theKey];
        NSObject *objOther = [other valueForKey:theKey];

        if (objSelf == nil && objOther == nil) {
            // considered equal, continue
        } else if (![objSelf isEqual:objOther]) {
            // NSValue, NSArray, NSString all have correctly implemented isEqual, so this works
            return NO;
        }
    }

    return YES;
}

- (NSUInteger)hashBasedOnKeys:(NSArray<NSString *> * _Nonnull)keys
{
    NSUInteger prime = 31;
    NSUInteger result = 1;

    for (NSString *theKey in keys) {
        NSObject *objSelf = [self valueForKey:theKey];
        result = prime * result + objSelf.hash;
    }

    return result;
}

@end
