//
//  PEPInternalSessionConcurrent.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 17.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPSessionConcurrentProtocol.h"

#import "sync_api.h"

@class PEPPassphraseCache;

NS_ASSUME_NONNULL_BEGIN

/**
Represents a real pEp session (in contrast to PEPSession, which is a fake session to handle to the client).
Never expose this class to the client.
- You must use one session on one thread only to assure no concurrent calls to one session take place.
- As long as you can assure the session is not accessed from anywhere else, it is OK to init/deinit a session on another thread than the one it is used on.
- N threads <-> N sessions, with the constraint that a session is never used in a pEpEngine call more than once at the same time.

Also the Engine requires that the first session is created on the main thread and is kept allive until all other created sessions have been terminated.
*/
@interface PEPInternalSessionConcurrent : NSObject <PEPSessionConcurrentProtocol>

@property (nonatomic) PEP_SESSION _Nullable session;

- (_Nullable instancetype)init;

/**
 Configures the session's unecryptedSubjectEnabled value.

 @param enabled Whether or not mail subjects should be encrypted when using this session
 */
- (void)configUnEncryptedSubjectEnabled:(BOOL)enabled;

/// Get the (global) passphrase cache
- (PEPPassphraseCache *)passphraseCache;

/// Get the (global) passphrase cache
+ (PEPPassphraseCache *)passphraseCache;

@end

NS_ASSUME_NONNULL_END