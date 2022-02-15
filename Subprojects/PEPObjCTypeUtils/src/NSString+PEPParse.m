//
//  NSString+PEPParse.m
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 9/2/22.
//

#import "NSString+PEPParse.h"

@implementation NSString (PEPParse)

- (NSString * _Nullable)stringBetweenString:(NSString * _Nonnull)start
                                  andString:(NSString * _Nonnull)end {
    // This will obtain the range of the string between strings and then return it.
    // First, we get the range of the separator in the current string
    NSRange startRange = [self rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        //We define the lower bound of the resultant string, which means just after the separator.
        targetRange.location = startRange.location + startRange.length;
        //The start of the resultant string will be the total lenght of the string minus the separator location.
        targetRange.length = [self length] - targetRange.location;
        // Then we get the end separator range.
        NSRange endRange = [self rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            // Update the resultant string lenght: substract the end separator.
            // So the resultant string length will be from the start separator up to the end separator, both are excluded.
            targetRange.length = endRange.location - targetRange.location;
            // Extract the resultant string.
            return [self substringWithRange:targetRange];
        }
    }
    return nil;
}

- (BOOL)isNumeric
{
    // Implementation taken from SO
    // http://stackoverflow.com/questions/6644004/how-to-check-if-nsstring-is-numeric
    NSScanner *sc = [NSScanner scannerWithString: self];
    // We can pass NULL because we don't actually need the value to test
    // To check if the string is numeric this is allowable.
    if ( [sc scanFloat:NULL] )
    {
        // Ensure nothing left in scanner so that "42foo" is not accepted.
        // ("42" would be consumed by scanFloat above leaving "foo".)
        return [sc isAtEnd];
    }
    // Couldn't even scan a float
    return NO;
}

@end
