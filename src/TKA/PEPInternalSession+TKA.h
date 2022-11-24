//
//  PEPInternalSession+TKA.h
//  PEPObjCAdapter
//
//  Created by Dirk Zimmermann on 18.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PEPObjCAdapterProtocols;

#import "PEPInternalSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPInternalSession (TKA)

/// Wraps the engine's `tka_subscribe_keychange`.
/// @note The delegate parameter will be stored with a strong reference.
///       Because it's strongly referenced, it is nullable intentionally, so you can set it to nil
///       in order to break memory cycles.
- (BOOL)tkaSubscribeWithKeychangeDelegate:(id<PEPTKADelegate> _Nullable)delegate
                                    error:(NSError * _Nullable * _Nullable)error;

/// Wraps the engine's `tka_request_temp_key`.
- (BOOL)tkaRequestTempKeyForMe:(PEPIdentity *)me
                       partner:(PEPIdentity *)partner
                         error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
