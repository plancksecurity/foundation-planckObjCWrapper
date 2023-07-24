//
//  NSString+FPR.m
//  PEPObjCTypes
//
//  Created by Dirk Zimmermann on 24/7/23.
//

#import "NSString+FPR.h"

@implementation NSString (FPR)

- (NSString *)normalizedFPR
{
    NSUInteger length = [self length];
    NSMutableString *result = [NSMutableString stringWithCapacity:length];

    for (NSUInteger i = 0; i < length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (c >= 'a' && c <= 'f') {
            [result appendFormat:@"%c", toupper(c)];
        } else if ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F')) {
            [result appendFormat:@"%c", c];
        }
    }

    return [NSString stringWithString:result];
}

@end
