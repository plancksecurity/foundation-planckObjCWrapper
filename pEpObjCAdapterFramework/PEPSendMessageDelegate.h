//
//  PEPSendMessageDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 05.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PEPMessage;

@protocol PEPSendMessageDelegate <NSObject>

- (PEP_STATUS)sendMessage:(PEPMessage * _Nonnull)message;

@end
