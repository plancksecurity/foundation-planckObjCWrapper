//
//  PEPCSVScanner.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 03.05.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPCSVScanner.h"

static unichar s_quoteChar = '"';

@interface PEPCSVScanner ()

@property (nonatomic) NSInteger position;
@property (nonatomic) NSInteger len;

@end;

@implementation PEPCSVScanner

- (instancetype _Nonnull )initWithString:(NSString * _Nonnull)string
{
    if (self = [super init]) {
        _string = string;
        _len = [string length];
    }
    return self;
}

- (NSString * _Nullable)nextString
{
    NSInteger startPos = NSNotFound;
    for (NSInteger thePos = self.position; thePos < self.len; thePos++) {
        if ([self startingQuoteAt:thePos]) {
            startPos = thePos + 1;
            for (NSInteger endPos = startPos; endPos < self.len; endPos++) {
                if ([self endingQuoteAt:endPos]) {
                    self.position = endPos + 1;
                    return [self.string substringWithRange:NSMakeRange(startPos, endPos - startPos)];
                }
            }
        }
    }
    return nil;
}

/**
 @return YES if the given position points to a starting quote.
 */
- (BOOL)startingQuoteAt:(NSInteger)pos
{
    // The last char can never be a starting quote
    if (pos >= self.len - 1) {
        return NO;
    }
    unichar ch1 = [self.string characterAtIndex:pos];
    unichar ch2 = [self.string characterAtIndex:pos + 1];
    if (ch1 == s_quoteChar && ch2 != s_quoteChar) {
        return YES;
    }
    return NO;
}

/**
 @return YES if the given position points to an ending quote.
 */
- (BOOL)endingQuoteAt:(NSInteger)pos
{
    unichar ch1 = [self.string characterAtIndex:pos];
    if (ch1 == s_quoteChar) {
        if (pos == self.len - 1) {
            return YES;
        }
        unichar ch2 = [self.string characterAtIndex:pos + 1];
        return ch2 != s_quoteChar;
    }
    return NO;
}

@end
