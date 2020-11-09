//
//  PEPInternalSessionTestNotifyHandshakeDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 29.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPNotifyHandshakeDelegate.h"

@interface PEPInternalSessionTestNotifyHandshakeDelegate : NSObject<PEPNotifyHandshakeDelegate>

/// This is set to YES if the _engine_ shut the sync loop down.
@property (nonatomic) BOOL engineDidShutdownKeySync;

/// Notify handshake was called with nil partner and signal
/// PEPSyncHandshakeSignalPassphraseRequired.
@property (nonatomic) BOOL notifyHandshakePassphraseRequired;

@end
