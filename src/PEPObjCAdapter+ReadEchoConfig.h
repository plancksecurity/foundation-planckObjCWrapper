//
//  PEPObjCAdapter+ReadEchoConfig.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 08.09.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#ifndef PEPObjCAdapter_ReadEchoConfig_h
#define PEPObjCAdapter_ReadEchoConfig_h

#import "PEPObjCAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPObjCAdapter (ReadEchoConfig)

+ (BOOL)echoProtocolEnabled;
+ (BOOL)echoInOutgoingMessageRatingPreviewEnabled;

/// Gets the currently set delegate for outgoing rating changes, triggered by the processing of echo messages.
+ (id<PEPNotifyHandshakeDelegate> _Nullable)echoOutgoingRatingChangeDelegate;

@end

NS_ASSUME_NONNULL_END

#endif /* PEPObjCAdapter_ReadEchoConfig_h */
