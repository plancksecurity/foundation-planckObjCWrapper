//
//  PEPIdentity+Address.m
//  pEpObjCAdapter
//
//  Created by Martín Brude on 9/2/22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import "PEPIdentity+Address.h"

@implementation PEPIdentity (Address)

- (nonnull instancetype)initWithUserId:(NSString *)userId
                              Protocol:(NSString *)protocol
                                    IP:(NSString *)ip
                                  port:(NSUInteger)port
{
    if (self = [super init]) {
        //Set address here
    }
    return self;
}

- (NSString * _Nullable)getIPV4 {
    return @"";//parse address and return ip
}

- (NSString * _Nullable)getIPV6 {
    return @"";//parse address and return ip
}

- (NSUInteger)getPort {
    return 1; // parse address and return port
}

- (NSString *)getProtocol {
    return @"1"; // parse address and return port
}


@end
