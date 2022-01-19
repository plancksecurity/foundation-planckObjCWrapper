//
//  PEPTKATestDelegate.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 19.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import "PEPTKATestDelegate.h"

@interface PEPTKATestDelegate ()

@property (nonatomic, readonly) XCTestExpectation *expectationKeyChangedCalled;
@property (nonatomic, readonly) XCTestExpectation *expectationDealloced;

@end

@implementation PEPTKATestDelegate

- (instancetype)initExpectationKeyChangedCalled:(XCTestExpectation *)expectationKeyChangedCalled
                           expectationDealloced:(XCTestExpectation *)expectationDealloced
{
    self = [super init];
    if (self) {
        _expectationKeyChangedCalled = expectationKeyChangedCalled;
        _expectationDealloced = expectationDealloced;
    }
    return self;
}

- (PEPStatus)tkaKeyChangeMe:(nonnull PEPIdentity *)me
                    partner:(nonnull PEPIdentity *)partner
                        key:(nonnull NSString *)key {
    [self.expectationKeyChangedCalled fulfill];
    return PEPStatusOK;
}

- (void)dealloc {
    [self.expectationDealloced fulfill];
}

@end
