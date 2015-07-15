//
//  pEpiOSAdapter.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEPiOSAdapter : NSObject

// start or stop keyserver lookup
// there is only one keyserver lookup thread

+ (void)startKeyserverLookup;
+ (void)stopKeyserverLookup;

@end
