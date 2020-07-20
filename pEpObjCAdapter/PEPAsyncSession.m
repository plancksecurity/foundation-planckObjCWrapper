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
#import "NSNumber+PEPRating.h"

static dispatch_queue_t queue;

@interface PEPAsyncSession ()
@end

@implementation PEPAsyncSession

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

+ (void)initialize
{
    if (self == [PEPAsyncSession class]) {
        queue = dispatch_queue_create("PEPAsyncSession.queue", DISPATCH_QUEUE_SERIAL);
    }
}

- (void)decryptMessage:(PEPMessage *)message //BUFF: done
                 flags:(PEPDecryptFlags)flags
             extraKeys:(PEPStringList * _Nullable)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *dstMessage,
                                 PEPStringList *keyList,
                                 PEPRating rating,
                                 PEPDecryptFlags flags))successCallback
{
    dispatch_async(queue, ^{
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

        if (newMessage) {
            successCallback(theMessage, newMessage, theExtraKeys, theRating, theFlags);
        } else {
            errorCallback(error);
        }
    });
}

- (void)reEvaluateMessage:(PEPMessage *)message //BUFF: done
                 xKeyList:(PEPStringList *_Nullable)xKeyList
                   rating:(PEPRating)rating
            errorCallback:(void (^)(NSError *error))errorCallback
          successCallback:(void (^)(PEPRating rating))successCallback
{
    dispatch_async(queue, ^{
        PEPRating theRating = rating;
        NSError *error = nil;

        BOOL result = [[PEPSession new]
                       reEvaluateMessage:message
                       xKeyList:xKeyList
                       rating:&theRating
                       status:nil
                       error:&error];

        if (result) {
            successCallback(theRating);
        } else {
            errorCallback(error);
        }
    });
}

- (void)encryptMessage:(PEPMessage *)message //BUFF: done
             extraKeys:(PEPStringList * _Nullable)extraKeys
             encFormat:(PEPEncFormat)encFormat
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback
{
    dispatch_async(queue, ^{
        PEPMessage *theMessage = [[PEPMessage alloc] initWithMessage:message];
        NSError *error = nil;
        PEPMessage *destMessage = [[PEPSession new]
                                   encryptMessage:theMessage
                                   extraKeys:extraKeys
                                   encFormat:encFormat
                                   status:nil
                                   error:&error];
        if (destMessage) {
            successCallback(theMessage, destMessage);
        } else {
            errorCallback(error);
        }
    });
}

- (void)encryptMessage:(PEPMessage *)message //BUFF: done
             extraKeys:(PEPStringList * _Nullable)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback
{
    dispatch_async(queue, ^{
        PEPMessage *theMessage = [[PEPMessage alloc] initWithMessage:message];
        NSError *error = nil;
        PEPMessage *destMessage = [[PEPSession new]
                                   encryptMessage:theMessage
                                   extraKeys:extraKeys
                                   status:nil
                                   error:&error];
        if (destMessage) {
            successCallback(theMessage, destMessage);
        } else {
            errorCallback(error);
        }
    });
}

- (void)encryptMessage:(PEPMessage *)message //BUFF: done
               forSelf:(PEPIdentity *)ownIdentity
             extraKeys:(PEPStringList * _Nullable)extraKeys
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback
{
    dispatch_async(queue, ^{
        PEPMessage *theMessage = [[PEPMessage alloc] initWithMessage:message];
        NSError *error = nil;
        PEPMessage *destMessage = [[PEPSession new]
                                   encryptMessage:theMessage
                                   forSelf:ownIdentity
                                   extraKeys:extraKeys
                                   status:nil
                                   error:&error];
        if (destMessage) {
            successCallback(theMessage, destMessage);
        } else {
            errorCallback(error);
        }
    });
}

- (void)encryptMessage:(PEPMessage *)message //BUFF: unused. (done)
                 toFpr:(NSString *)toFpr
             encFormat:(PEPEncFormat)encFormat
                 flags:(PEPDecryptFlags)flags
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPMessage *srcMessage,
                                 PEPMessage *destMessage))successCallback
{
    dispatch_async(queue, ^{
        PEPMessage *theMessage = [[PEPMessage alloc] initWithMessage:message];
        NSError *error = nil;
        PEPMessage *destMessage = [[PEPSession new]
                                   encryptMessage:theMessage
                                   toFpr:toFpr
                                   encFormat:encFormat
                                   flags:flags
                                   status:nil
                                   error:&error];
        if (destMessage) {
            successCallback(theMessage, destMessage);
        } else {
            errorCallback(error);
        }
    });
}

- (void)outgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                   errorCallback:(void (^)(NSError *error))errorCallback
                 successCallback:(void (^)(PEPRating rating))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSNumber *ratingNum = [[PEPSession new] outgoingRatingForMessage:theMessage error:&error];
        if (ratingNum) {
            successCallback(ratingNum.pEpRating);
        } else {
            errorCallback(error);
        }
    });
}

@end
