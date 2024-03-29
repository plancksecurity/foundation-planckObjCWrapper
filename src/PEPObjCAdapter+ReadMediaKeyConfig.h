//
//  PEPObjCAdapter+ReadMediaKeyConfig.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 15.09.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#ifndef PEPObjCAdapter_ReadMediaKeyConfig_h
#define PEPObjCAdapter_ReadMediaKeyConfig_h

#import "PEPObjCAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@class PEPMediaKeyPair;

@interface PEPObjCAdapter (ReadMediaKeyConfig)

+ (NSArray<PEPMediaKeyPair *> * _Nullable)mediaKeys;

@end

NS_ASSUME_NONNULL_END

#endif /* PEPObjCAdapter_ReadMediaKeyConfig_h */
