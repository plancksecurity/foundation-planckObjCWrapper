//
//  PEPTKATestDelegate.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 19.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import "PEPTKATestDelegate.h"

@implementation PEPTKATestDelegate

- (instancetype)initExpectationKeyChangedCalled:(XCTestExpectation *)expectationKeyChangedCalled
{
    self = [super init];
    if (self) {
        _expectationKeyChangedCalled = expectationKeyChangedCalled;
    }
    return self;
}

- (PEPStatus)tkaKeyChangeMe:(nonnull PEPIdentity *)me
                    partner:(nonnull PEPIdentity *)partner
                        key:(nonnull NSString *)key {
    [self.expectationKeyChangedCalled fulfill];
    return PEPStatusOK;
}

@end
