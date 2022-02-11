//
//  PEPIdentity+Address.m
//  pEpObjCAdapter
//
//  Created by Martín Brude on 9/2/22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import "PEPIdentity+Address.h"
#import "NSString+Parse.h"

@implementation PEPIdentity (Address)

NSString * _Nonnull const IPV4Format = @"pEp+%@:%@:%lu";
NSString * _Nonnull const IPV6Format = @"pEp+%@:[%@]:%lu";

NSString* IPV6Separator = @"::";
NSString* IPV4Separator = @":";

- (nonnull instancetype)initWithUserID:(NSString *)userID
                              protocol:(NSString *)protocol
                                    ip:(NSString *)ip
                                  port:(NSUInteger)port;
{
    if (self = [super init]) {
        self.userID = userID;
        BOOL isIPV6 = [ip containsString:IPV6Separator];
        self.address = [NSString stringWithFormat:isIPV6 ? IPV6Format : IPV4Format, protocol, ip, (unsigned long) port];
    }
    return self;
}

- (NSString * _Nullable)getIPV4 {
    return [self.address stringBetweenString:IPV4Separator andString:IPV4Separator];
}

- (NSString * _Nullable)getIPV6 {
    NSString *protocol = [self getProtocol];
    NSUInteger port = [self getPort];
    NSString *lowerBound = [NSString stringWithFormat:@"%@%@:[", @"pep+", protocol];
    NSString *upperBound = [NSString stringWithFormat:@":%lu:", port];
    return [self.address stringBetweenString:lowerBound andString:upperBound];
}

- (NSUInteger)getPort {
    return [[[self.address componentsSeparatedByString:@":"] lastObject] longLongValue];
}

- (NSString * _Nullable)getProtocol {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"+:"];
    NSArray *parts = [self.address componentsSeparatedByCharactersInSet:characterSet];
    if (parts.count > 1) {
        return parts[1];
    }
    return nil;
}

@end


