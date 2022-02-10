//
//  NSString+Parse.m
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 9/2/22.
//

#import "NSString+Parse.h"

@implementation NSString (Parse)

- (NSString * _Nullable)stringBetweenString:(NSString * _Nonnull)start
                                  andString:(NSString * _Nonnull)end {
    // Get the range of the separator in the current string
    NSRange startRange = [self rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        //Define the lower bound of the substring, which means just after the separator.
        targetRange.location = startRange.location + startRange.length;
        //The start of the substring will be the total lenght of the string minus the separator location.
        targetRange.length = [self length] - targetRange.location;
        // Get the end separator range.
        NSRange endRange = [self rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            // Update the substring lenght: substract the end separator.
            // So substring length will be from the start separator up to the end separator.
            targetRange.length = endRange.location - targetRange.location;
            // Extract the substring
            return [self substringWithRange:targetRange];
        }
    }
    return nil;
}

@end
