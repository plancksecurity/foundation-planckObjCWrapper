//
//  PEPSyncSendMessageDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 05.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "pEpEngine.h"

@class PEPMessage;

@interface PEPSyncSendMessageDelegate : NSObject

- (PEP_STATUS)sendMessage:(PEPMessage * _Nonnull)message;

@end
