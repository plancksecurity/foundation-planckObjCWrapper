//
//  PEPTKADelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 18.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPObjCTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PEPTKADelegate <NSObject>

/// From tka_api.h, the `tka_keychange_t` callback.
- (PEPStatus)tkaKeyChangeMe:(PEPIdentity *)me partner:(PEPIdentity *)partner key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
