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

+ (NSError *)errorWithPEPStatus:(PEP_STATUS)status
                       userInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict;

+ (NSError *)errorWithPEPStatus:(PEP_STATUS)status;

@end
