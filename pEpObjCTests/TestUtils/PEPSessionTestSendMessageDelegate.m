//
//  PEPSessionTestSendMessageDelegate.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 29.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPSessionTestSendMessageDelegate.h"

@implementation PEPSessionTestSendMessageDelegate

- (PEP_STATUS)sendMessage:(PEPMessage * _Nonnull)message {
    return PEP_STATUS_OK;
}

@end
