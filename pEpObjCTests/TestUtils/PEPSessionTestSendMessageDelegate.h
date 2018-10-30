//
//  PEPSessionTestSendMessageDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 29.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPSyncSendMessageDelegate.h"

@class PEPMessage;

@interface PEPSessionTestSendMessageDelegate : NSObject<PEPSyncSendMessageDelegate>

@property (nonatomic, nullable) PEPMessage *lastMessage;

@end
