//
//  PEPSyncHandshakeResult.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 19.11.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#ifndef PEPSyncHandshakeResult_h
#define PEPSyncHandshakeResult_h

typedef NS_CLOSED_ENUM(int, PEPSyncHandshakeResult) {
    PEPSyncHandshakeResultCancel = -1, // SYNC_HANDSHAKE_CANCEL
    PEPSyncHandshakeResultAccepted = 0, // SYNC_HANDSHAKE_ACCEPTED
    PEPSyncHandshakeResultRejected = 1 // SYNC_HANDSHAKE_REJECTED
};

#endif /* PEPSyncHandshakeResult_h */
