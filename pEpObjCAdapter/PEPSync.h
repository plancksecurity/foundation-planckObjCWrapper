//
//  PEPSync.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "pEpEngine.h"

PEP_STATUS messageToSendObjc(struct _message *msg);
int inject_sync_eventObjc(SYNC_EVENT ev, void *management);

@class PEPSyncSendMessageDelegate;

@interface PEPSync : NSObject

+ (void)setPEPSyncSendMessageDelegate:
(PEPSyncSendMessageDelegate * _Nullable)syncSendMessageDelegate;

+ (PEPSyncSendMessageDelegate * _Nullable)syncSendMessageDelegate;

@property (nonatomic, nullable, weak) PEPSyncSendMessageDelegate *syncSendMessageDelegate;

@end
