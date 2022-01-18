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

// MARK: - Cheap fake of the engine's TKA API

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

// MARK: - Internal Vars

/// The global TKA delegate.
id<PEPTKADelegate> s_tkaDelegate = nil;

@implementation PEPInternalSession (TKA)

// MARK: - Internal API

- (BOOL)tkaSubscribeKeychangeDelegate:(id<PEPTKADelegate> _Nullable)delegate
                                error:(NSError * _Nullable * _Nullable)error {
    s_tkaDelegate = delegate;
    return YES;
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

    return [PEPStatusNSErrorUtil setError:error fromPEPStatus:(PEPStatus) engineStatus];
}

@end

PEP_STATUS tkaKeychangeCallback(const pEp_identity *me,
                                const pEp_identity *partner,
                                const char *key) {
    if (s_tkaDelegate == nil) {
        return PEP_ILLEGAL_VALUE;
    }

    PEPIdentity *objcMe = [PEPObjCTypeConversionUtil pEpIdentityfromStruct:me];
    PEPIdentity *objcPartner = [PEPObjCTypeConversionUtil pEpIdentityfromStruct:partner];

    return (PEP_STATUS) [s_tkaDelegate
                         tkaKeyChangeMe:objcMe
                         partner:objcPartner
                         key:[NSString stringWithCString:key encoding:NSUTF8StringEncoding]];
}
