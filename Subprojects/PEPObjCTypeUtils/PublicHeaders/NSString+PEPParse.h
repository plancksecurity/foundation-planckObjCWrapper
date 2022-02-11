//
//  NSString+PEPParse.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 9/2/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (PEPParse)

/// Retrieve the substring between two strings, if can find it.
/// Otherwise, will return nil.
///
/// For example:
/// ["One two three" stringBetweenString:@"One " andString: @" three"]; it will return @"two".
///
/// @param start The start separator. Will not be included in the substring.
/// @param end The end separator. Will not be included in the substring.
- (NSString * _Nullable)stringBetweenString:(NSString * _Nonnull)start andString:(NSString * _Nonnull)end;

@end

NS_ASSUME_NONNULL_END
