//
//  NSString+FPR.h
//  PEPObjCTypes
//
//  Created by Dirk Zimmermann on 24/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FPR)

/// The normalized equivalent of this string interpreted as a fingerint.
- (NSString *)normalizedFPR;

@end

NS_ASSUME_NONNULL_END
