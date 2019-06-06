//
//  PEPSizeTest.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 27.05.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPObjCAdapterFramework.h"

#import "pEpEngine.h"
#import "message_api.h"
#import "sync_api.h"

@interface PEPSizeTest : XCTestCase

@end

@implementation PEPSizeTest

- (void)testEnumSizes {
    XCTAssertEqual(sizeof(PEP_STATUS), sizeof(PEPStatus));
    XCTAssertEqual(sizeof(PEP_rating), sizeof(PEPRating));
    XCTAssertEqual(sizeof(PEP_decrypt_flags), sizeof(PEPDecryptFlags));
    XCTAssertEqual(sizeof(PEP_enc_format), sizeof(PEPEncFormat));
    XCTAssertEqual(sizeof(identity_flags), sizeof(PEPIdentityFlags));
    XCTAssertEqual(sizeof(sync_handshake_signal), sizeof(PEPSyncHandshakeSignal));
    XCTAssertEqual(sizeof(sync_handshake_result), sizeof(PEPSyncHandshakeResult));
    XCTAssertEqual(sizeof(PEP_comm_type), sizeof(PEPCommType));
    XCTAssertEqual(sizeof(PEP_msg_direction), sizeof(PEPMsgDirection));
    XCTAssertEqual(sizeof(PEP_color), sizeof(PEPColor));
    XCTAssertEqual(sizeof(content_disposition_type), sizeof(PEPContentDisposition));
}

@end
