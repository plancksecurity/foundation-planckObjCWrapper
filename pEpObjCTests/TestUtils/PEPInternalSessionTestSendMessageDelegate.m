//
//  PEPInternalSessionTestSendMessageDelegate.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 29.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPInternalSessionTestSendMessageDelegate.h"

#import "PEPObjCAdapter.h"

@implementation PEPInternalSessionTestSendMessageDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messages = [NSMutableArray new];
    }
    return self;
}

- (PEPStatus)sendMessage:(PEPMessage * _Nonnull)message {
    [self.messages addObject:message];
    self.lastMessage = message;
    return PEPStatusOK;
}

@end
