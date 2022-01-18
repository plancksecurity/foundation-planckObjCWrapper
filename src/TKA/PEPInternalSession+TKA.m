//
//  PEPInternalSession+TKA.m
//  PEPObjCAdapter_iOS
//
//  Created by Dirk Zimmermann on 18.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import "PEPInternalSession+TKA.h"

#import "PEPStatusNSErrorUtil.h"

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
