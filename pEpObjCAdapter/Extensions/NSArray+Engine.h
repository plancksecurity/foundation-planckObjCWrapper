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
#import "bloblist.h"

@class PEPIdentity;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Engine)

+ (NSArray *)arrayFromStringlist:(stringlist_t *)stringList;
+ (NSArray<PEPIdentity *> *)arrayFromIdentityList:(identity_list *)identityList;
+ (NSArray *)arrayFromStringPairlist:(stringpair_list_t * _Nonnull)stringPairList;
+ (NSArray *)arrayFromBloblist:(bloblist_t * _Nonnull)blobList;

- (stringlist_t * _Nullable)toStringList;

/// Converts `NSArray<PEPIdentity *>` to an engine identity list
- (identity_list * _Nullable)toIdentityList;

- (stringpair_list_t *)toStringPairlist;

@end

NS_ASSUME_NONNULL_END
