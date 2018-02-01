//
//  pEpiOSAdapter.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPSession.h"
#include "sync_app.h"

@class PEPLanguage;

@protocol PEPKeyManagementDelegate <NSObject>
- (void)identityUpdated:(_Nonnull id)identity;
@end

@protocol PEPSyncDelegate <NSObject>
- (PEP_STATUS)notifyHandshakeWithSignal:(sync_handshake_signal)signal me:(_Nonnull id)me partner:(_Nonnull id)partner;
- (PEP_STATUS)sendMessage:(_Nonnull id)msg;
- (PEP_STATUS)fastPolling:(bool)isfast;
@end

@interface PEPObjCAdapter : NSObject

/**
 Sets Engine config for unecryptedSubjectEnabled to the given value on all Sessions created by
 this adapter.

 @param enabled Whether or not mail subjects should be encrypted
 */
+ (void)setUnecryptedSubjectEnabled:(BOOL)enabled;

/**
 The HOME URL, where all pEp related files will be stored.
 */
+ (NSURL * _Nonnull)homeURL;

/**
 Start keyserver lookup.
 - Note: There is only one keyserver lookup thread
 */
+ (void)startKeyserverLookup;

/**
 Stop keyserver lookup.
 */
+ (void)stopKeyserverLookup;

+ (void)setupTrustWordsDB;
+ (void)setupTrustWordsDB:(NSBundle * _Nonnull)rootBundle;

/**
 Start Sync.
 - Note: There is only one Sync session and thread
 */
+ (void)startSync:(_Nonnull id <PEPSyncDelegate>)delegate;

/**
 Stop Sync.
 */
+ (void)stopSync;

@end
