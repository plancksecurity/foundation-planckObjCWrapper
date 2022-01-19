//
//  PEPTKATestDelegate.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 19.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "PEPObjCAdapter.h"
#import "PEPSessionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPTKATestDelegate : NSObject <PEPTKADelegate>

@property (nonatomic, readonly) XCTestExpectation *expectationKeyChangedCalled;

- (instancetype)initExpectationKeyChangedCalled:(XCTestExpectation *)expectationKeyChangedCalled;

@end

NS_ASSUME_NONNULL_END
