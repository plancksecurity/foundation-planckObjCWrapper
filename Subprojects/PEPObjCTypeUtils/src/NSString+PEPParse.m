//
//  NSString+PEPParse.m
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 9/2/22.
//

#import "NSString+PEPParse.h"

@implementation NSString (PEPParse)

- (NSString * _Nullable)stringBetweenString:(NSString *)startStr andString:(NSString *)endStr {
    NSString *param = @"";
    NSRange startRange = [self rangeOfString:startStr];
    if (startRange.location != NSNotFound) {
        param = [self substringFromIndex:startRange.location + startRange.length];
        NSRange end = [param rangeOfString:endStr];
        if (end.location != NSNotFound) {
            param = [param substringToIndex:end.location];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
    return param;
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
