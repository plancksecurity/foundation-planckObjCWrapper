//
//  PEPAttachment.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 16.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPAttachment.h"

@implementation PEPAttachment

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        self.data = data;
    }
    return self;
}

@end
