//
//  XCTestCase+PEPSession.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 09.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "XCTestCase+PEPSession.h"

#import "PEPObjCAdapter_iOS.h"
#import "PEPTestUtils.h"
#import "NSNumber+PEPRating.h"

@implementation XCTestCase (PEPSession)

#pragma mark - Normal session to async

- (PEPRating)ratingForIdentity:(PEPIdentity *)identity
{
    PEPSession *asyncSession = [PEPSession new];

    __block PEPRating resultingRating = PEPRatingB0rken;

    XCTestExpectation *expRated = [self expectationWithDescription:@"expRated"];
    [asyncSession ratingForIdentity:identity
                      errorCallback:^(NSError * _Nonnull error) {
        XCTFail();
        [expRated fulfill];
    } successCallback:^(PEPRating rating) {
        resultingRating = rating;
        [expRated fulfill];
    }];
    [self waitForExpectations:@[expRated] timeout:PEPTestInternalSyncTimeout];

    return resultingRating;
}

- (PEPIdentity * _Nullable)mySelf:(PEPIdentity * _Nonnull)identity
                            error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];

    XCTestExpectation *expMyself = [self expectationWithDescription:@"expMyself"];
    __block PEPIdentity *identityMyselfed = nil;
    __block NSError *errorMyself = nil;
    [asyncSession mySelf:identity
           errorCallback:^(NSError * _Nonnull theError) {
        errorMyself = theError;
        [expMyself fulfill];
    } successCallback:^(PEPIdentity * _Nonnull identity) {
        identityMyselfed = identity;
        [expMyself fulfill];
    }];
    [self waitForExpectations:@[expMyself] timeout:PEPTestInternalSyncTimeout];

    *error = errorMyself;

    XCTAssertNotNil(identityMyselfed);

    if (error) {
        *error = errorMyself;
    }

    return identityMyselfed;
}

- (NSArray<NSString *> * _Nullable)trustwordsForFingerprint:(NSString * _Nonnull)fingerprint
                                                 languageID:(NSString * _Nonnull)languageID
                                                  shortened:(BOOL)shortened
                                                      error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSArray<NSString *> *result = nil;
    __block NSError *theError = nil;
    [asyncSession trustwordsForFingerprint:fingerprint
                                languageID:languageID
                                 shortened:shortened
                             errorCallback:^(NSError * _Nonnull error) {
        theError = error;
        [exp fulfill];
    } successCallback:^(NSArray<NSString *> * _Nonnull trustwords) {
        [exp fulfill];
        result = trustwords;
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (PEPIdentity * _Nullable)updateIdentity:(PEPIdentity * _Nonnull)identity
                                    error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *expUpdateIdent = [self expectationWithDescription:@"expUpdateIdent"];
    __block PEPIdentity *identTestUpdated = nil;
    __block NSError *theError = nil;
    [asyncSession updateIdentity:identity
                   errorCallback:^(NSError * _Nonnull error) {
        theError = error;
        [expUpdateIdent fulfill];
    } successCallback:^(PEPIdentity * _Nonnull identity) {
        identTestUpdated = identity;
        [expUpdateIdent fulfill];
    }];
    [self waitForExpectations:@[expUpdateIdent] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return identTestUpdated;
}

- (NSNumber * _Nullable)outgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                                           error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSNumber *result = nil;
    __block NSError *theError = nil;
    [asyncSession outgoingRatingForMessage:theMessage
                             errorCallback:^(NSError * _Nonnull error) {
        theError = error;
        [exp fulfill];
    } successCallback:^(PEPRating rating) {
        result = [NSNumber numberWithPEPRating:rating];
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                               encFormat:(PEPEncFormat)encFormat
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block PEPMessage *result = nil;
    __block NSError *theError = nil;
    [asyncSession encryptMessage:message
                       extraKeys:extraKeys
                       encFormat:encFormat
                   errorCallback:^(NSError * _Nonnull error) {
        theError = error;
        [exp fulfill];
    } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
        result = destMessage;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage * _Nonnull)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block PEPMessage *result = nil;
    __block NSError *theError = nil;
    [asyncSession encryptMessage:message
                       extraKeys:extraKeys
                   errorCallback:^(NSError * _Nonnull error) {
        theError = error;
        [exp fulfill];
    } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
        result = destMessage;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)trustPersonalKey:(PEPIdentity * _Nonnull)identity
                   error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession trustPersonalKey:identity
                     errorCallback:^(NSError * _Nonnull error) {
        result = NO;
        theError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)keyResetTrust:(PEPIdentity * _Nonnull)identity
                error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession keyResetTrust:identity
                  errorCallback:^(NSError * _Nonnull error) {
        result = NO;
        theError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)keyMistrusted:(PEPIdentity *)identity error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession keyMistrusted:identity
                  errorCallback:^(NSError * _Nonnull error) {
        result = NO;
        theError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)enableSyncForIdentity:(PEPIdentity * _Nonnull)identity
                        error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession enableSyncForIdentity:identity
                  errorCallback:^(NSError * _Nonnull error) {
        result = NO;
        theError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)disableSyncForIdentity:(PEPIdentity * _Nonnull)identity
                         error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession disableSyncForIdentity:identity
                           errorCallback:^(NSError * _Nonnull error) {
        result = NO;
        theError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (NSString * _Nullable)getLogWithError:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSString *result = nil;
    __block NSError *theError = nil;
    [asyncSession getLog:^(NSError * _Nonnull error) {
        result = nil;
        theError = error;
        [exp fulfill];
    } successCallback:^(NSString *theLog) {
        result = theLog;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (NSString * _Nullable)getTrustwordsIdentity1:(PEPIdentity * _Nonnull)identity1
                                     identity2:(PEPIdentity * _Nonnull)identity2
                                      language:(NSString * _Nullable)language
                                          full:(BOOL)full
                                         error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSString *result = nil;
    __block NSError *theError = nil;
    [asyncSession getTrustwordsIdentity1:identity1
                               identity2:identity2
                                language:language
                                    full:full
                           errorCallback:^(NSError * _Nonnull error) {
        result = nil;
        theError = error;
        [exp fulfill];
    } successCallback:^(NSString * _Nonnull trustwords) {
        result = trustwords;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (NSNumber * _Nullable)isPEPUser:(PEPIdentity * _Nonnull)identity
                            error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block NSNumber *result = nil;
    __block NSError *theError = nil;
    [asyncSession isPEPUser:identity
              errorCallback:^(NSError * _Nonnull error) {
        result = nil;
        theError = error;
        [exp fulfill];
    } successCallback:^(BOOL enabled) {
        result = [NSNumber numberWithBool:enabled];
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)trustOwnKeyIdentity:(PEPIdentity * _Nonnull)identity
                      error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession trustOwnKeyIdentity:identity
                        errorCallback:^(NSError * _Nonnull error) {
        result = NO;
        theError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)keyReset:(PEPIdentity * _Nonnull)identity
     fingerprint:(NSString * _Nullable)fingerprint
           error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;
    [asyncSession keyReset:identity
               fingerprint:fingerprint
             errorCallback:^(NSError * _Nonnull error) {
        result = NO;
        theError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

#pragma mark - Group API

- (PEPGroup * _Nullable)groupCreateGroupIdentity:(PEPIdentity *)groupIdentity
                                         manager:(PEPIdentity *)managerIdentity
                                         members:(NSArray<PEPIdentity *> *)memberIdentities
                                           error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block PEPGroup *result = nil;
    __block NSError *theError = nil;
    [asyncSession groupCreateGroupIdentity:groupIdentity
                           managerIdentity:managerIdentity
                          memberIdentities:memberIdentities
                             errorCallback:^(NSError *error) {
        theError = error;
        [exp fulfill];
    }
                           successCallback:^(PEPGroup *group) {
        result = group;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)groupJoinGroupIdentity:(PEPIdentity * _Nonnull)groupIdentity
                memberIdentity:(PEPIdentity * _Nonnull)memberIdentity
                         error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;

    [asyncSession groupJoinGroupIdentity:groupIdentity
                          memberIdentity:memberIdentity
                           errorCallback:^(NSError * _Nonnull error) {
        result = NO;
        theError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)groupDissolveGroupIdentity:(PEPIdentity *)groupIdentity
                   managerIdentity:(PEPIdentity *)managerIdentity
                             error:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    __block BOOL result = NO;
    __block NSError *theError = nil;

    [asyncSession groupDissolveGroupIdentity:groupIdentity
                             managerIdentity:managerIdentity
                               errorCallback:^(NSError * _Nonnull error) {
        result = NO;
        theError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];

    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = theError;
    }
    return result;
}

- (BOOL)groupInviteMemberGroupIdentity:(PEPIdentity *)groupIdentity
                        memberIdentity:(PEPIdentity *)memberIdentity
                                 error:(NSError * _Nullable * _Nullable)error
{
    return NO;
}

- (BOOL)groupRemoveMemberGroupIdentity:(PEPIdentity *)groupIdentity
                        memberIdentity:(PEPIdentity *)memberIdentity
                                 error:(NSError * _Nullable * _Nullable)error
{
    return NO;
}

- (NSNumber * _Nullable)groupRatingGroupIdentity:(PEPIdentity *)groupIdentity
                                 managerIdentity:(PEPIdentity *)managerIdentity
                                           error:(NSError * _Nullable * _Nullable)error
{
    return nil;
}

@end
