//
//  PEPInternalSession+TKA.m
//  PEPObjCAdapter_iOS
//
//  Created by Dirk Zimmermann on 18.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import "PEPInternalSession+TKA.h"

#import "PEPObjCTypeUtils.h"

#import "PEPStatusNSErrorUtil.h"

typedef PEP_STATUS (*tka_keychange_t)(const pEp_identity *me,
                                      const pEp_identity *partner,
                                      const char *key);

PEP_STATUS tka_subscribe_keychange(PEP_SESSION session,
                                   tka_keychange_t callback) {
    return PEP_ILLEGAL_VALUE;
}

PEP_STATUS tka_request_temp_key(PEP_SESSION session,
                                pEp_identity *me,
                                pEp_identity *partner) {
    return PEP_ILLEGAL_VALUE;
}

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
    pEp_identity *engineMe = [PEPObjCTypeConversionUtil structFromPEPIdentity:me];
    if (engineMe == NULL) {
        return [PEPStatusNSErrorUtil setError:error fromPEPStatus:PEPStatusIllegalValue];
    }

    pEp_identity *enginePartner = [PEPObjCTypeConversionUtil structFromPEPIdentity:partner];
    if (enginePartner == NULL) {
        return [PEPStatusNSErrorUtil setError:error fromPEPStatus:PEPStatusIllegalValue];
    }

    PEP_STATUS engineStatus = tka_request_temp_key(self.session, engineMe, enginePartner);

    free_identity(engineMe);
    free_identity(enginePartner);

    // not implemented
    //PEP_STATUS engineStatus = PEP_ILLEGAL_VALUE;

    return [PEPStatusNSErrorUtil setError:error fromPEPStatus:(PEPStatus) engineStatus];
}

@end
