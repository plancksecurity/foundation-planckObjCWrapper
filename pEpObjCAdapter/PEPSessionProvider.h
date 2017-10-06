//
//  PEPSessionProvider.h
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 09.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PEPSession;

@interface PEPSessionProvider : NSObject

+ (PEPSession * _Nonnull)session;

+ (void)cleanup;

@end
