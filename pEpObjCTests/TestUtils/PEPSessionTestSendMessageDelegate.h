//
//  PEPSessionTestSendMessageDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 29.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPSendMessageDelegate.h"

@class PEPMessage;

@interface PEPSessionTestSendMessageDelegate : NSObject<PEPSendMessageDelegate>

@property (nonatomic, nonnull) NSMutableArray<PEPMessage *> *messages;

@end
