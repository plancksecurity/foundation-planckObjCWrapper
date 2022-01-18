//
//  PEPSessionProtocolTKA.h
//  PEPObjCAdapterProtocols
//
//  Created by Dirk Zimmermann on 18.01.22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PEPSessionProtocolTKA <NSObject>

/*
/// Wraps the engine's `tka_subscribe_keychange`.
- (void)tkaSubscribeKeychangeDelegate:(id<PEPTKADelegate>)delegate
                        errorCallback:(void (^)(NSError *error))errorCallback
                      successCallback:(void (^)());

/// Wraps the engine's `tka_request_temp_key`.
- (void)tkaRequestTempKeyMe:(PEPIdentity *)me partner:(PEPIdentity *)partner
              errorCallback:(void (^)(NSError *error))errorCallback
            successCallback:(void (^)());
*/

@end

NS_ASSUME_NONNULL_END
