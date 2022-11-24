//
//  PEPInternalSessionTestSendMessageDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 29.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PEPObjCAdapter_iOS;

@class PEPMessage;

@interface PEPInternalSessionTestSendMessageDelegate : NSObject<PEPSendMessageDelegate>

/**
 Meant for waiting for changes in `messages`, since `NSMutableArray`
 doesn't support KVO.
 */
@property (nonatomic, nullable) PEPMessage *lastMessage;

@property (nonatomic, nonnull) NSMutableArray<PEPMessage *> *messages;

@end
