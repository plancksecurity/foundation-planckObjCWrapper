//
//  PEPEqualableTools.m
//  PEPObjCTypes
//

#import "PEPEqualableTools.h"

@implementation PEPEqualableTools

+ (BOOL)object:(NSObject * _Nonnull)object
     isEqualTo:(NSObject * _Nonnull)other
   basedOnKeys:(NSArray<NSString *> * _Nonnull)keys
{
    for (NSString *theKey in keys) {
        NSObject *valueObject = [object valueForKey:theKey];
        NSObject *valueOther = [other valueForKey:theKey];
        if (valueObject == nil && valueOther == nil) {
            continue;
        } else {
            if ([valueObject isKindOfClass:[NSString class]] && [valueOther isKindOfClass:[NSString class]]) {
                NSString *valueString = [(NSString *)valueObject lowercaseString];
                NSString *valueOtherString = [(NSString *)valueOther lowercaseString];
                return [valueString isEqualToString:valueOtherString];
            }
            if (![valueObject isEqual:valueOther]) {
                return NO;
            }
        }
    }

    return YES;
}

+ (NSUInteger)hashForObject:(NSObject * _Nonnull)object basedOnKeys:(NSArray<NSString *> * _Nonnull)keys
{
    NSUInteger prime = 31;
    NSUInteger result = 1;

    for (NSString *theKey in keys) {
        NSObject *value = [object valueForKey:theKey];
        result = prime * result + value.hash;
    }

    return result;
}

@end
