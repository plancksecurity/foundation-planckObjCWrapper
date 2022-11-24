//
//  PEPTKATestDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 19.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@import PEPObjCAdapterProtocols;

NS_ASSUME_NONNULL_BEGIN

@interface PEPTKATestDelegate : NSObject <PEPTKADelegate>

/// The key that has been received by the engine.
@property (nonatomic, readonly, nullable) NSString *keyReceived;

- (instancetype)initExpKeyChangedCalled:(XCTestExpectation *)expKeyChangedCalled
                           expDealloced:(XCTestExpectation *)expDealloced;

@end

NS_ASSUME_NONNULL_END
