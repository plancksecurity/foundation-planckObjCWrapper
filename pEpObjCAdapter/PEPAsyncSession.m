//
//  PEPAsyncSession.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 17.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPAsyncSession.h"

#import "PEPMessage.h"
#import "PEPEngineTypes.h"
#import "PEPSession.h"

@implementation PEPAsyncSession

- (void)decryptMessage:(PEPMessage *)message
                 flags:(PEPDecryptFlags)flags
             extraKeys:(PEPStringList *)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *message,
                                 PEPStringList *keyList,
                                 PEPRating rating,
                                 PEPDecryptFlags flags))successCallback
{
    PEPMessage *theMessage = [[PEPMessage alloc] initWithMessage:message];

    PEPDecryptFlags theFlags = flags;
    PEPRating theRating;
    PEPStringList *theExtraKeys = extraKeys;
    PEPStatus status;
    NSError *error = nil;

    PEPMessage *newMessage = [[PEPSession new] decryptMessage:theMessage
                                               flags:&theFlags
                                              rating:&theRating
                                           extraKeys:&theExtraKeys
                                              status:&status
                                               error:&error];

    if (error) {
        errorCallback(error);
    } else {
        successCallback(newMessage, theExtraKeys, theRating, theFlags);
    }
}

@end
