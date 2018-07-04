//
//  PEPObjHolder.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.07.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPObjHolder.h"

@implementation PEPObjHolder

- (instancetype)initWithObject:(id _Nullable)object
{
    if (self = [super init]) {
        _object = object;
    }
    return self;
}

@end
