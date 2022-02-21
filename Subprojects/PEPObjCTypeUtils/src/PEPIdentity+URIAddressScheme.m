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

NSString *const _Nonnull IPV6Separator = @"::";
NSString *const _Nonnull IPV4Separator = @":";

@implementation PEPIdentity (URIAddressScheme)

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
    if ([self.address containsString:IPV6Separator]) {
        return nil;
    }
    return [self.address stringBetweenString:IPV4Separator andString:IPV4Separator];
}

- (NSString * _Nullable)getIPV6 {
    NSString *protocol = [self getProtocol];
    NSUInteger port = [self getPort];
    NSString *lowerBound = [NSString stringWithFormat:@"%@:[", protocol];
    NSString *upperBound = [NSString stringWithFormat:@"]:%lu", port];
    return [self.address stringBetweenString:lowerBound andString:upperBound];
}

- (NSUInteger)getPort {
    NSArray *parts = [self.address componentsSeparatedByString:IPV4Separator];
    NSString *probablyThePort = [parts lastObject];
    if (![probablyThePort isNumeric]) {
        return 0;
    }
    return [probablyThePort longLongValue];
}

- (NSString * _Nullable)getProtocol {
    // As the address scheme for pEp4IPsec is "$PROTOCOL:$IPV4:$PORT" or "$PROTOCOL:[$IPV6]:$PORT",
    // we can separate the protocol using the IPV4Separator, colon `:`.
    NSArray *parts = [self.address componentsSeparatedByString:IPV4Separator];
    return [parts firstObject];
}

@end


