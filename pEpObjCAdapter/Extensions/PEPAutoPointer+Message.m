//
//  PEPAutoPointer+Message.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 24.11.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPAutoPointer+Message.h"

@implementation PEPAutoPointer (Message)

- (instancetype)initWithMessage:(message *)message
{
    self = [super init];
    if (self) {
        _thePointer = message;
    }
    return self;
}

@end
