//
//  PEPInternalSession+TKA.m
//  PEPObjCAdapter_iOS
//
//  Created by Dirk Zimmermann on 18.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import "PEPInternalSession+TKA.h"

#import "PEPStatusNSErrorUtil.h"

typedef PEP_STATUS (*tka_keychange_t)(
         const pEp_identity *me,
         const pEp_identity *partner,
         const char *key
     );

 PEP_STATUS tka_subscribe_keychange(
         PEP_SESSION session,
         tka_keychange_t callback
     );

 PEP_STATUS tka_request_temp_key(
         PEP_SESSION session,
         pEp_identity *me,
         pEp_identity *partner
     );

/// The global TKA delegate.
id<PEPTKADelegate> s_tkaDelegate = nil;

@implementation PEPInternalSession (TKA)

- (BOOL)tkaSubscribeKeychangeDelegate:(id<PEPTKADelegate>)delegate
                                error:(NSError * _Nullable * _Nullable)error {
    // not implemented
    return [PEPStatusNSErrorUtil setError:error fromPEPStatus:PEPStatusIllegalValue];
}

- (BOOL)tkaRequestTempKeyMe:(PEPIdentity *)me partner:(PEPIdentity *)partner
                      error:(NSError * _Nullable * _Nullable)error {
    // not implemented
    return [PEPStatusNSErrorUtil setError:error fromPEPStatus:PEPStatusIllegalValue];
}

@end
