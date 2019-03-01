//
//  NSNumber+PEPRating.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 13.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "NSNumber+PEPRating.h"

#import "message_api.h"

@implementation NSNumber (Extension)

- initWithPEPRating:(PEPRating)pEpRating
{
    return [self initWithInt:pEpRating];
}

- initWithPEPRatingInternal:(PEP_rating)pEpRating
{
    return [self initWithInt:pEpRating];
}

- (PEPRating)pEpRating
{
    return self.intValue;
}

- (PEP_rating)pEpRatingInternal
{
    return self.intValue;
}

+ (NSNumber *)numberWithPEPRating:(PEPRating)pEpRating
{
    return [[NSNumber alloc] initWithPEPRating:pEpRating];
}

+ (NSNumber *)numberWithPEPRatingInternal:(PEP_rating)pEpRating
{
    return [[NSNumber alloc] initWithPEPRatingInternal:pEpRating];
}

@end
