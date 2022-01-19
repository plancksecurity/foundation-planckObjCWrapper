//
//  PEPSessionProtocolTKA.h
//  PEPObjCAdapterProtocols
//
//  Created by Dirk Zimmermann on 18.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPTKADelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PEPSessionProtocolTKA <NSObject>

/// Wraps the engine's `tka_subscribe_keychange`.
///
/// Sets the delegate that will receive key changes via TKA. The delegate will be owned by the adapter and can be unset
/// (by calling this method with a nil delegate). That's the reason the delegate parameter is nullable.
- (void)tkaSubscribeKeychangeDelegate:(id<PEPTKADelegate> _Nullable)delegate
                        errorCallback:(void (^)(NSError *error))errorCallback
                      successCallback:(void (^)(void))successCallback;

/// Wraps the engine's `tka_request_temp_key`.
- (void)tkaRequestTempKeyMe:(PEPIdentity *)me partner:(PEPIdentity *)partner
              errorCallback:(void (^)(NSError *error))errorCallback
            successCallback:(void (^)(void))successCallback;

@end

NS_ASSUME_NONNULL_END
