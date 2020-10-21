//
//  NSError+PEP.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 20.02.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "pEpEngine.h"

/**
 Extension for creating `NSError`s from `PEP_STATUS`
 */
@interface NSError (Extension)

/**
 A possible string representation of the error code if this is a pEp error.
 @return A string representation of the pEp error code, if it's in the pEp domain.
 */
- (NSString * _Nullable)pEpErrorString;

@end
