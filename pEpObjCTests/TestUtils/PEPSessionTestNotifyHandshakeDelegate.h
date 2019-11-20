//
//  PEPSessionTestNotifyHandshakeDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 29.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPNotifyHandshakeDelegate.h"

@interface PEPSessionTestNotifyHandshakeDelegate : NSObject<PEPNotifyHandshakeDelegate>

/// This is set to YES if the _engine_ shut the sync loop down.
@property (nonatomic) BOOL engineDisabledKeySync;

@end
