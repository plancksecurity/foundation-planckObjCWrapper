//
//  PEPSessionTestSendMessageDelegate.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 29.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPSessionTestSendMessageDelegate.h"

#import "PEPMessage.h"

@implementation PEPSessionTestSendMessageDelegate

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
