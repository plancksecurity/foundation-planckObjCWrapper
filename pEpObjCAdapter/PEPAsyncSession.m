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
#import "PEPIdentity.h"

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

- (void)outgoingRatingForMessage:(PEPMessage *)theMessage //BUFF: WIP
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

- (void)outgoingRatingPreviewForMessage:(PEPMessage *)theMessage //BUFF: unused
                          errorCallback:(void (^)(NSError *error))errorCallback
                        successCallback:(void (^)(PEPRating rating))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSNumber *ratingNum = [[PEPSession new]
                               outgoingRatingPreviewForMessage:theMessage
                               error:&error];
        if (ratingNum) {
            successCallback(ratingNum.pEpRating);
        } else {
            errorCallback(error);
        }
    });
}

- (void)ratingForIdentity:(PEPIdentity *)identity
                      errorCallback:(void (^)(NSError *error))errorCallback
                    successCallback:(void (^)(PEPRating rating))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSNumber *ratingNum = [[PEPSession new]
                               ratingForIdentity:identity
                               error:&error];
        if (ratingNum) {
            successCallback(ratingNum.pEpRating);
        } else {
            errorCallback(error);
        }
    });
}

- (void)trustwordsForFingerprint:(NSString *)fingerprint
                      languageID:(NSString *)languageID
                       shortened:(BOOL)shortened
                   errorCallback:(void (^)(NSError *error))errorCallback
                 successCallback:(void (^)(NSArray<NSString *> * _Nullable trustwords))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSArray *trustwords = [[PEPSession new]
                               trustwordsForFingerprint:fingerprint
                               languageID:languageID
                               shortened:shortened
                               error:&error];
        if (!error) {
            successCallback(trustwords);
        } else {
            errorCallback(error);
        }
    });
}

- (void)mySelf:(PEPIdentity *)identity
 errorCallback:(void (^)(NSError *error))errorCallback
successCallback:(void (^)(PEPIdentity *identity))successCallback
{
    __block PEPIdentity *theIdentity = [[PEPIdentity alloc] initWithIdentity:identity];

    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSession new] mySelf:theIdentity error:&error];
        if (success) {
            successCallback(theIdentity);
        } else {
            errorCallback(error);
        }
    });
}

- (void)updateIdentity:(PEPIdentity *)identity
         errorCallback:(void (^)(NSError *error))errorCallback
       successCallback:(void (^)(PEPIdentity *identity))successCallback
{
    __block PEPIdentity *theIdentity = [[PEPIdentity alloc] initWithIdentity:identity];

    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSession new] updateIdentity:theIdentity error:&error];
        if (success) {
            successCallback(theIdentity);
        } else {
            errorCallback(error);
        }
    });
}

- (void)trustPersonalKey:(PEPIdentity *)identity
           errorCallback:(void (^)(NSError *error))errorCallback
         successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSession new] trustPersonalKey:identity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)keyMistrusted:(PEPIdentity *)identity
        errorCallback:(void (^)(NSError *error))errorCallback
      successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSession new] keyMistrusted:identity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)keyResetTrust:(PEPIdentity *)identity
        errorCallback:(void (^)(NSError *error))errorCallback
      successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSession new] keyResetTrust:identity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)enableSyncForIdentity:(PEPIdentity *)identity
                errorCallback:(void (^)(NSError *error))errorCallback
              successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSession new] enableSyncForIdentity:identity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)disableSyncForIdentity:(PEPIdentity *)identity
                 errorCallback:(void (^)(NSError *error))errorCallback
               successCallback:(void (^)(void))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        BOOL success = [[PEPSession new] disableSyncForIdentity:identity error:&error];
        if (success) {
            successCallback();
        } else {
            errorCallback(error);
        }
    });
}

- (void)queryKeySyncEnabledForIdentity:(PEPIdentity *)identity
                                   errorCallback:(void (^)(NSError *error))errorCallback
                                 successCallback:(void (^)(BOOL enabled))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSNumber *boolNum = [[PEPSession new] queryKeySyncEnabledForIdentity:identity
                                                                       error:&error];
        if (boolNum) {
            successCallback(boolNum.boolValue);
        } else {
            errorCallback(error);
        }
    });
}

- (void)importKey:(NSString *)keydata
    errorCallback:(void (^)(NSError *error))errorCallback
  successCallback:(void (^)(NSArray<PEPIdentity *> *identities))successCallback
{
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSArray *identities = [[PEPSession new] importKey:keydata error:&error];
        if (identities) {
            successCallback(identities);
        } else {
            errorCallback(error);
        }
    });
}

@end
