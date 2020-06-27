//
//  NSString+CodePoints.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 27.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CodePoints)

/// The number of unicode code-points in this string.
/// - Note: The caller is responsible for doing any normalization before this call.
- (NSUInteger)numberOfCodePoints;

@end

NS_ASSUME_NONNULL_END
