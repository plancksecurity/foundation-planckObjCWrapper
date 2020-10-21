//
//  NSNumber+PEPRating+Internal.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 28.02.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#ifndef NSNumber_PEPRating_Internal_h
#define NSNumber_PEPRating_Internal_h

#import <Foundation/Foundation.h>

#import "message_api.h"

/**
 Extension for wrapping the engine's PEP_rating inside a NSNumber.
 */
@interface NSNumber (Internal)

@property (nonatomic, readonly) PEP_rating pEpRatingInternal;

- initWithPEPRatingInternal:(PEP_rating)pEpRating;

+ (NSNumber *)numberWithPEPRatingInternal:(PEP_rating)pEpRating;

@end

#endif /* NSNumber_PEPRating_Internal_h */
