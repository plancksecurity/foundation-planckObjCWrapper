//
//  NSNumber+PEPRating.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 13.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#ifndef NSNumber_PEPRating_h
#define NSNumber_PEPRating_h

#import <Foundation/Foundation.h>

#import <PEPObjCAdapterFramework/PEPTypes.h>
#import <PEPObjCAdapterFramework/PEPEngineTypes.h>
#import <PEPObjCAdapterFramework/PEPRating.h>

/**
 Extension for wrapping the engine's PEP_rating inside a NSNumber.
 */
@interface NSNumber (Extension)

@property (nonatomic, readonly) PEPRating pEpRating;

- initWithPEPRating:(PEPRating)pEpRating;

+ (NSNumber *)numberWithPEPRating:(PEPRating)pEpRating;

@end

#endif
