//
//  PEPAsyncSessionTest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 18.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPObjCAdapterFramework.h"

#import "PEPTestUtils.h"
#import "PEPAsyncSession.h"

@interface PEPAsyncSessionTest : XCTestCase

@end

@implementation PEPAsyncSessionTest

- (void)testMailToMyself
{
    PEPSession *session = [PEPSession new];

    // Our test user :
    // pEp Test Alice (test key don't use) <pep.test.alice@pep-project.org>
    // 4ABE3AAF59AC32CFE4F86500A9411D176FF00E97
    XCTAssertTrue([PEPTestUtils importBundledKey:@"6FF00E97_sec.asc" session:session]);

    PEPIdentity *identAlice = [[PEPIdentity alloc]
                               initWithAddress:@"pep.test.alice@pep-project.org"
                               userID:ownUserId
                               userName:@"pEp Test Alice"
                               isOwn:YES
                               fingerPrint:@"4ABE3AAF59AC32CFE4F86500A9411D176FF00E97"];

    NSError *error = nil;
    XCTAssertTrue([session mySelf:identAlice error:&error]);
    XCTAssertNil(error);

    PEPMessage *msg = [PEPMessage new];
    msg.from = identAlice;
    msg.to = @[identAlice];
    msg.shortMessage = @"Mail to Myself";
    msg.longMessage = @"This is a text content";
    msg.direction = PEPMsgDirectionOutgoing;

    NSNumber *numRating = [self testOutgoingRatingForMessage:msg session:session error:&error];
    XCTAssertNotNil(numRating);
    XCTAssertNil(error);
    XCTAssertEqual(numRating.pEpRating, PEPRatingTrustedAndAnonymized);

    PEPMessage *encMsg = [session encryptMessage:msg extraKeys:nil status:nil error:&error];
    XCTAssertNotNil(encMsg);
    XCTAssertNil(error);

    XCTestExpectation *expectationDecrypted = [self expectationWithDescription:@"expectationDecrypted"];

    [[PEPAsyncSession new]
     decryptMessage:encMsg
     flags:0
     extraKeys:@[]
     errorCallback:^(NSError *error) {
        XCTFail();
        [expectationDecrypted fulfill];
    }
     successCallback:^(PEPMessage * srcMessage,
                       PEPMessage * dstMessage,
                       PEPStringList * keyList,
                       PEPRating rating,
                       PEPDecryptFlags flags) {
        XCTAssertNotNil(dstMessage);
        XCTAssertEqual(rating, PEPRatingTrustedAndAnonymized);
        [expectationDecrypted fulfill];
    }];

    [self waitForExpectations:@[expectationDecrypted] timeout:PEPTestInternalSyncTimeout];
}

- (NSNumber * _Nullable)testOutgoingRatingForMessage:(PEPMessage * _Nonnull)theMessage
                                             session:(PEPSession *)session
                                               error:(NSError * _Nullable * _Nullable)error
{
    NSNumber *ratingOriginal = [session outgoingRatingForMessage:theMessage error:error];
    NSNumber *ratingPreview = [session outgoingRatingPreviewForMessage:theMessage error:nil];
    XCTAssertEqual(ratingOriginal, ratingPreview);
    return ratingOriginal;
}

@end
