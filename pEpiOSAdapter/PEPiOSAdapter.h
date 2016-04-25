//
//  pEpiOSAdapter.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "message_api.h"

@protocol PEPKeyManagementDelegate <NSObject>

- (void)identityWillBeUpdated:(id)identity;
- (void)identityWasUpdated:(id)identity;
- (void)managementIdle;
- (void)managementBusy;
- (void)managementStarted;
- (void)managementFinishing;

@property bool allowKeyserverLookup;

@end

@interface PEPiOSAdapter : NSObject

+ (void)setupTrustWordsDB;
+ (void)setupTrustWordsDB:(NSBundle *)rootBundle;

+ (void)setKeyManagementDelegate:(id<PEPKeyManagementDelegate>)delegate;

/**
 Start key management thread.
 - Note: There is only one keyserver lookup thread
 */
+ (void)startKeyManagement;
+ (void)stopKeyManagement;


@end
