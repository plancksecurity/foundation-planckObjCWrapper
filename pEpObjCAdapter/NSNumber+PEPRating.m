//
//  NSNumber+PEPRating.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 13.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "NSNumber+PEPRating.h"

@implementation NSNumber (Extension)

- initWithPEPRating:(PEP_rating)pEpRating
{
    return [self initWithInt:pEpRating];
}

- (PEP_rating)pEpRating
{
    return self.intValue;
}

+ (NSNumber *)numberWithBool:(PEP_rating)pEpRating
{
    return [[NSNumber alloc] initWithPEPRating:pEpRating];
}

@end
