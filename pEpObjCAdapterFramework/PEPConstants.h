//
//  PEPConstants.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 01.03.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Constants

/** Optional field "X-pEp-Version" */
extern NSString *const _Nonnull kXpEpVersion;

/** Optional field "X-EncStatus" */
extern NSString *const _Nonnull kXEncStatus;

/** Optional field "X-KeyList" */
extern NSString *const _Nonnull kXKeylist;

/** The key of the header for certain sync messages, "pEp-auto-consume". */
extern NSString *const _Nonnull kPepHeaderAutoConsume;

/** The positive value of the header for "pEp-auto-consume". */
extern NSString *const _Nonnull kPepValueAutoConsumeYes;

/// The key to the flags, which control pEp sync behaviour of an identity
extern NSString *const _Nonnull kPepFlags;
