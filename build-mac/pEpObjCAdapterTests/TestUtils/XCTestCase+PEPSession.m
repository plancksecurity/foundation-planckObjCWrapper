//
//  XCTestCase+PEPSession.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 09.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

@import PEPObjCAdapter;

#import "XCTestCase+PEPSession.h"

#import "PEPTestUtils.h"

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

- (BOOL)keyResetAllOwnKeysError:(NSError * _Nullable * _Nullable)error
{
    PEPSession *asyncSession = [PEPSession new];

    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];

    __block BOOL result = NO;
    __block NSError *asyncError = nil;

    [asyncSession keyResetAllOwnKeys:^(NSError * _Nonnull error) {
        asyncError = error;
        [exp fulfill];
    } successCallback:^{
        result = YES;
        [exp fulfill];
    }];

    [self waitForExpectations:@[exp] timeout:PEPTestInternalSyncTimeout];
    if (error) {
        *error = asyncError;
    }

    return result;
}

- (BOOL)syncReinit:(NSError * _Nullable *)error
{
    PEPSession *asyncSession = [PEPSession new];

    __block NSError *outerError = nil;

    XCTestExpectation *expSyncReinit = [self expectationWithDescription:@"expSyncReinit"];
    [asyncSession syncReinit:^(NSError * _Nonnull innerError) {
        outerError = innerError;
        [expSyncReinit fulfill];
    } successCallback:^{
        [expSyncReinit fulfill];
    }];

    [self waitForExpectations:@[expSyncReinit] timeout:PEPTestInternalSyncTimeout];

    if (outerError) {
        *error = outerError;
        return NO;
    }

    return YES;
}

- (NSArray<NSString *> * _Nullable)importExtraKey:(NSString *)extraKey
                                            error:(NSError * _Nullable *)error
{
    PEPSession *asyncSession = [PEPSession new];

    __block NSError *asyncError = nil;
    __block NSArray *asyncFingerprints = nil;

    XCTestExpectation *expKeyImported = [self expectationWithDescription:@"expSyncReinit"];

    [asyncSession importExtraKey:extraKey errorCallback:^(NSError * _Nonnull error) {
        asyncError = error;
        [expKeyImported fulfill];
    } successCallback:^(NSArray<NSString *> * _Nonnull fingerprints) {
        asyncFingerprints = fingerprints;
        [expKeyImported fulfill];
    }];

    [self waitForExpectations:@[expKeyImported] timeout:PEPTestInternalSyncTimeout];

    if (asyncError) {
        *error = asyncError;
        return nil;
    }

    return asyncFingerprints;
}

#pragma mark - Signing

- (NSString *)signText:(NSString *)stringToSign
                 error:(NSError **)error
{
    PEPSession *asyncSession = [PEPSession new];

    __block NSError *asyncError = nil;
    __block NSString *resultingSignature = nil;

    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];

    [asyncSession signText:stringToSign
             errorCallback:^(NSError * _Nonnull error) {
        asyncError = error;
        [expectation fulfill];
    } successCallback:^(NSString * _Nonnull signature) {
        resultingSignature = signature;
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:PEPTestInternalSyncTimeout];

    if (asyncError) {
        *error = asyncError;
        return nil;
    }

    return resultingSignature;
}

- (BOOL)verifyText:(NSString *)textToVerify
         signature:(NSString *)signature
          verified:(BOOL *)verified
             error:(NSError **)error
{
    PEPSession *asyncSession = [PEPSession new];

    __block NSError *asyncError = nil;
    __block BOOL asyncVerified = NO;

    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];

    [asyncSession verifyText:textToVerify
                   signature:signature
               errorCallback:^(NSError * _Nonnull error) {
        asyncError = error;
        [expectation fulfill];
    } successCallback:^(BOOL verified) {
        asyncVerified = verified;
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:PEPTestInternalSyncTimeout];

    if (asyncError) {
        *error = asyncError;
        return NO;
    }

    *verified = asyncVerified;

    return YES;
}

@end
