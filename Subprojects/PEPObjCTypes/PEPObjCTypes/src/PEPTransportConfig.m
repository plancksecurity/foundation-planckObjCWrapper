//
//  PEPTransportConfig.m
//  PEPObjCTypes
//
//  Created by Andreas Buff on 16.08.21.
//

#import "PEPTransportConfig.h"

@implementation PEPTransportConfig

- (instancetype)initWithSize:(Size)size port:(UInt16)port
{
    self = [super init];
    if (self) {
        _size = size;
        _port = port;
    }
    return self;
}

@end
