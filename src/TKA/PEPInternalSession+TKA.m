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
#import "PEPIdentity+PEPConvert.h"

// MARK: - Cheap fake of the engine's TKA API

// NOTE: IOSAD-239
// Delete this section once the engine has TKA implemented,
// and instead simply include the correct header.

typedef PEP_STATUS (*tka_keychange_t)(const pEp_identity *me,
                                      const pEp_identity *partner,
                                      const char *key);

tka_keychange_t g_tkaKeyChangeCallback = NULL;

PEP_STATUS tka_subscribe_keychange(PEP_SESSION session,
                                   tka_keychange_t callback) {
    g_tkaKeyChangeCallback = callback;
    return PEP_STATUS_OK;
}

const char *s_mockedTmpKey =
"base64"
"line2"
"line3";

PEP_STATUS tka_request_temp_key(PEP_SESSION session,
                                pEp_identity *me,
                                pEp_identity *partner) {
    if (g_tkaKeyChangeCallback == NULL) {
        return PEP_ILLEGAL_VALUE;
    }

    int64_t nsDelta = 1000000000; // 1s in nanoseconds
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, nsDelta);

    pEp_identity *meCopy = identity_dup(me);
    pEp_identity *partnerCopy = identity_dup(partner);

    dispatch_after(delay, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        g_tkaKeyChangeCallback(meCopy, partnerCopy, s_mockedTmpKey);
        free_identity(meCopy);
        free_identity(partnerCopy);
    });

    return PEP_STATUS_OK;
}

// MARK: - Internal Vars and Forward Declarations

/// The global TKA delegate.
id<PEPTKADelegate> s_tkaDelegate = nil;

PEP_STATUS tkaKeychangeCallback(const pEp_identity *me,
                                const pEp_identity *partner,
                                const char *key);

@implementation PEPInternalSession (TKA)

// MARK: - Internal Session API

- (BOOL)tkaSubscribeWithKeychangeDelegate:(id<PEPTKADelegate> _Nullable)delegate
                                    error:(NSError * _Nullable * _Nullable)error {
    s_tkaDelegate = delegate;

    if (delegate != nil) {
        tka_subscribe_keychange(self.session, tkaKeychangeCallback);
    } else {
        tka_subscribe_keychange(self.session, NULL);
    }

    return YES;
}

- (BOOL)tkaRequestTempKeyForMe:(PEPIdentity *)me
                       partner:(PEPIdentity *)partner
                         error:(NSError * _Nullable * _Nullable)error {
    pEp_identity *engineMe = [me toStruct];
    if (engineMe == NULL) {
        return [PEPStatusNSErrorUtil setError:error fromPEPStatus:PEPStatusIllegalValue];
    }

    pEp_identity *enginePartner = [partner toStruct];
    if (enginePartner == NULL) {
        return [PEPStatusNSErrorUtil setError:error fromPEPStatus:PEPStatusIllegalValue];
    }

    PEP_STATUS engineStatus = tka_request_temp_key(self.session, engineMe, enginePartner);

    free_identity(engineMe);
    free_identity(enginePartner);

    return ![PEPStatusNSErrorUtil setError:error fromPEPStatus:(PEPStatus) engineStatus];
}

@end

/// This is the C callback that is hit by the engine's TKA mechanism, if a delegate gets set by the client.
PEP_STATUS tkaKeychangeCallback(const pEp_identity *me,
                                const pEp_identity *partner,
                                const char *key) {
    if (s_tkaDelegate == nil) {
        return PEP_ILLEGAL_VALUE;
    }
    PEPIdentity *objcMe = [PEPIdentity fromStruct:me];
    PEPIdentity *objcPartner = [PEPIdentity fromStruct:partner];

    [s_tkaDelegate
     tkaKeyChangeForMe:objcMe
     partner:objcPartner
     key:[NSString stringWithCString:key encoding:NSUTF8StringEncoding]];

    return PEP_STATUS_OK;
}
