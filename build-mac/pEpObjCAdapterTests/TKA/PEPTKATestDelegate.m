//
//  PEPTKATestDelegate.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 19.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import "PEPTKATestDelegate.h"

@interface PEPTKATestDelegate ()

@property (nonatomic, readonly) XCTestExpectation *expKeyChangedCalled;
@property (nonatomic, readonly) XCTestExpectation *expDealloced;

@end

@implementation PEPTKATestDelegate

- (instancetype)initExpKeyChangedCalled:(XCTestExpectation *)expKeyChangedCalled
                           expDealloced:(XCTestExpectation *)expDealloced
{
    self = [super init];
    if (self) {
        _expKeyChangedCalled = expKeyChangedCalled;
        _expDealloced = expDealloced;
    }
    return self;
}

- (PEPStatus)tkaKeyChangeForMe:(nonnull PEPIdentity *)me
                       partner:(nonnull PEPIdentity *)partner
                           key:(nonnull NSString *)key {
    [self.expKeyChangedCalled fulfill];
    return PEPStatusOK;
}

- (void)dealloc {
    [self.expDealloced fulfill];
}

@end
