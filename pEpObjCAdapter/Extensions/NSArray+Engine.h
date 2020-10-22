//
//  NSArray+Engine.h
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "stringlist.h"
#import "identity_list.h"

@class PEPIdentity;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Engine)

+ (NSArray *)arrayFromStringlist:(stringlist_t *)stringList;
+ (NSArray<PEPIdentity *> *)arrayFromIdentityList:(identity_list *)identityList;
+ (NSArray * _Nonnull)arrayFromStringPairlist:(stringpair_list_t * _Nonnull)stringPairList;

- (stringlist_t * _Nullable)toStringList;

/// Converts `NSArray<PEPIdentity *>` to an engine identity list
- (identity_list * _Nullable)toIdentityList;

@end

NS_ASSUME_NONNULL_END
