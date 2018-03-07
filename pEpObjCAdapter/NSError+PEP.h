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

/**
 If the given status indicates an error, tries to set the given error accordingly.
 @return YES if the given status indicates an error condition, NO otherwise.
 */
+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromStatus:(PEP_STATUS)status;

@end
