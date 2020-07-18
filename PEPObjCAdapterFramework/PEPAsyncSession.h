//
//  PEPAsyncSession.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 17.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPEngineTypes.h"
#import "PEPTypes.h"

@class PEPMessage;

NS_ASSUME_NONNULL_BEGIN

@interface PEPAsyncSession : NSObject

- (void)decryptMessage:(PEPMessage *)message
                 flags:(PEPDecryptFlags)flags
             extraKeys:(PEPStringList *)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *message,
                                 PEPStringList *keyList,
                                 PEPRating rating,
                                 PEPDecryptFlags flags))successCallback;

@end

NS_ASSUME_NONNULL_END
