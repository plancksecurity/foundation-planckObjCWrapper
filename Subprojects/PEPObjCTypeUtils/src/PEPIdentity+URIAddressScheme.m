//
//  PEPIdentity+URIAddressScheme.m
//  pEpObjCAdapter
//
//  Created by Martín Brude on 9/2/22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import "PEPIdentity+URIAddressScheme.h"
#import "NSString+PEPParse.h"

NSString *const _Nonnull kURIscheme = @"pEp.cc";

NSString *const _Nonnull closeBracket = @"]";
NSString *const _Nonnull openBracket = @"[";
NSString *const _Nonnull IPV4Format = @"%@:%@:%lu";
NSString *const _Nonnull IPV6Format = @"%@:[%@]:%lu";
NSString *const _Nonnull colon = @":";

@implementation PEPIdentity (URIAddressScheme)

- (nonnull instancetype)initWithUserID:(NSString *)userID
                              protocol:(NSString *)protocol
                                  ipV4:(NSString *)ip
                                  port:(NSUInteger)port
{
    if (self = [super init]) {
        self.userID = userID;
        self.isIPV4 = YES;
        self.address = [NSString stringWithFormat:IPV4Format, protocol, ip, (unsigned long) port];
    }
    return self;
}

- (nonnull instancetype)initWithUserID:(NSString *)userID
                              protocol:(NSString *)protocol
                                  ipV6:(NSString *)ip
                                  port:(NSUInteger)port
{
    if (self = [super init]) {
        self.userID = userID;
        self.isIPV6 = YES;
        self.address = [NSString stringWithFormat:IPV6Format, protocol, ip, (unsigned long) port];
    }
    return self;
}

- (NSString * _Nullable)getIPV4 {
    if (!self.isIPV4) {
        return nil;
    }
    return [self.address stringBetweenString:colon andString:colon];
}

- (NSString * _Nullable)getIPV6 {
    if (!self.isIPV6) {
        return nil;
    }
    return [self.address stringBetweenString:openBracket andString:closeBracket];
}

- (NSUInteger)getPort {
    if ((!self.isIPV4 && !self.isIPV6) || ![self.address containsString:colon]) {
        return 0;
    }
    NSArray *parts = [self.address componentsSeparatedByString:colon];
    NSString *probablyThePort = [parts lastObject];
    if (![probablyThePort isNumeric]) {
        return 0;
    }
    return [probablyThePort longLongValue];
}

- (NSString * _Nullable)getProtocol {
    if ((!self.isIPV4 && !self.isIPV6) || ![self.address containsString:colon]) {
        return nil;
    }
    NSArray *parts = [self.address componentsSeparatedByString:colon];
    return [parts firstObject];
}


@end


