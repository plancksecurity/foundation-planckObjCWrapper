//
//  PEPSession.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 17.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PEPObjCAdapterFramework/PEPEngineTypes.h>
#import <PEPObjCAdapterFramework/PEPTypes.h>
#import <PEPObjCAdapterFramework/PEPSessionProtocol.h>

@class PEPMessage;
@class PEPIdentity;
@class PEPLanguage;


NS_ASSUME_NONNULL_BEGIN

@interface PEPSession : NSObject <PEPSessionProtocol>

@end

NS_ASSUME_NONNULL_END
