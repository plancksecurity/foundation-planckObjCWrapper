//
//  NSString+PEPParse.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 9/2/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (PEPParse)

/// Retrieve the first substring between two strings that can be found.
/// If can't find one or both param will return nil.
/// If can find the params but there is nothing in between, will return an empty string.
///
/// For example:
/// [@"One two three" stringBetweenString:@"One " andString: @" three"]; it will return @"two".
/// [@"One 1 three One 2 three One 3 three" stringBetweenString:@"One " andString: @" three"]; it will return @"1".
/// [@"Onethree" stringBetweenString:@"One " andString: @" three"]; it will return @"".
/// [@"One three" stringBetweenString:@"Two " andString: @" Four"]; it will return nil.
/// [@"One three" stringBetweenString:@"One " andString: @" Four"]; it will return nil.
///
/// @param start The start separator. Will not be included in the substring.
/// @param end The end separator. Will not be included in the substring.
///
/// @return The resultant (sub)string.
- (NSString * _Nullable)stringBetweenString:(NSString *)start andString:(NSString *)end;

@end

NS_ASSUME_NONNULL_END
