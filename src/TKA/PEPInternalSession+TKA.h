//
//  PEPInternalSession+TKA.h
//  PEPObjCAdapter_iOS
//
//  Created by Dirk Zimmermann on 18.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPInternalSession.h"

#import "PEPTKADelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPInternalSession (TKA)

/// Wraps the engine's `tka_subscribe_keychange`.
- (BOOL)tkaSubscribeKeychangeDelegate:(id<PEPTKADelegate>)delegate
                                error:(NSError * _Nullable * _Nullable)error;

/// Wraps the engine's `tka_request_temp_key`.
- (BOOL)tkaRequestTempKeyMe:(PEPIdentity *)me partner:(PEPIdentity *)partner
                      error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
