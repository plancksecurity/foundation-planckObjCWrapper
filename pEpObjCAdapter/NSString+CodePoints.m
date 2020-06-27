//
//  NSString+CodePoints.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 27.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "NSString+CodePoints.h"

@implementation NSString (CodePoints)

- (NSUInteger)numberOfCodePoints
{
    return [self lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
}

@end
