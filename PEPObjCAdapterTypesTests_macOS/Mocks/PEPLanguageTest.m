//
//  PEPLanguageTest.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPLanguageTest.h"

@implementation PEPLanguageTest

- (instancetype)init {
    if (self = [super init]) {
        self.code = @"cat";
        self.name = @"Català";
        self.sentence = @"Bon profit";
    }

    return  self;
}

@end
