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

- (void)identityUpdated:(id)identity;

@end

@interface PEPiOSAdapter : NSObject

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
+ (void)setupTrustWordsDB:(NSBundle *)rootBundle;

+ (void)startKeyManagementWithDelegate:(id<PEPKeyManagementDelegate>)delegate;
+ (void)setKeyManagementDelegate:(id<PEPKeyManagementDelegate>)delegate;

@end
