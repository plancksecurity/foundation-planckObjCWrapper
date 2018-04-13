//
//  NSNumber+PEPRating.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 13.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "message_api.h"

/**
 Extension for handling the engine's PEP_rating inside a NSNumber.
 */
@interface NSNumber (Extension)

- initWithPEPRating:(PEP_rating)pEpRating;
- (PEP_rating)pEpRating;

@end
