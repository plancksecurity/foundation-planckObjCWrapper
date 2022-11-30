//
//  PEPSendMessageDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 05.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PEPObjCTypes;

/**
 Delegate that receives notifications when the engine needs to send out messages on its behalf.
 */
@protocol PEPSendMessageDelegate <NSObject>

/**
 Called when the engine wants to send out a message, which is generally invisible to the user.

 @param message The message to be sent out.
 @return A status value that can indicate failure if it's already obvious at call-time (sync)
         that there is something wrong with the message. Can only cover immediate problems.
         Issues that can occur while sending the message (later) cannot (and should not)
         be communicated back to the engine. The app should simply retry.
 */
- (PEPStatus)sendMessage:(PEPMessage * _Nonnull)message;

@end
