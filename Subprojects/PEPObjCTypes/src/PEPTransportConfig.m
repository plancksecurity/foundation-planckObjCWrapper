//
//  PEPTransportConfig.m
//  PEPObjCTypes
//
//  Created by Andreas Buff on 16.08.21.
//

#import "PEPTransportConfig.h"

@implementation PEPTransportConfig

- (instancetype)initWithPort:(UInt16)port
{
    self = [super init];
    if (self) {
        _port = port;
    }
    return self;
}

@end
