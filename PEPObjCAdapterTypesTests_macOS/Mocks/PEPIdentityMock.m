//
//  PEPIdentityMock.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 26/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPIdentityMock.h"

@implementation PEPIdentityMock

- (instancetype)init {
    if (self = [super init]) {
        self.address = @"test@host.com";
    }

    return  self;
}

@end
