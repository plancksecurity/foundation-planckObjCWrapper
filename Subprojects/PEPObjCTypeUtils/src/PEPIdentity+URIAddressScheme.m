//
//  PEPIdentity+URIAddressScheme.m
//  pEpObjCAdapter
//
//  Created by Martín Brude on 9/2/22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import "PEPIdentity+URIAddressScheme.h"

NSString *const _Nonnull IPV4Format = @"%@:%@:%lu";
NSString *const _Nonnull IPV6Format = @"%@:[%@]:%lu";

@implementation PEPIdentity (URIAddressScheme)

- (nonnull instancetype)initWithUserID:(NSString *)userID
                              protocol:(NSString *)protocol
                                  ipV4:(NSString *)ipV4
                                  port:(NSUInteger)port
{
    if (self = [super init]) {
        self.userID = userID;
        self.address = [NSString stringWithFormat:IPV4Format, protocol, ipV4, (unsigned long) port];
    }
    return self;
}

- (nonnull instancetype)initWithUserID:(NSString *)userID
                              protocol:(NSString *)protocol
                                  ipV6:(NSString *)ipV6
                                  port:(NSUInteger)port
{
    if (self = [super init]) {
        self.userID = userID;
        self.address = [NSString stringWithFormat:IPV6Format, protocol, ipV6, (unsigned long) port];
    }
    return self;
}

- (NSString * _Nullable)getProtocol {
    NSArray *parts = [self getParts];
    if (parts) {
        return [parts firstObject];
    }
    return nil;
}

- (NSString * _Nullable)getPort {
    NSArray *parts = [self getParts];
    if (parts) {
        return [parts lastObject];
    }
    return nil;
}

- (NSString * _Nullable)getIPV6 {
    NSString *ip = [self getIP];
    if (ip) {
        if ([ip hasPrefix:@"["] && [ip hasSuffix:@"]"]) {
            return [ip substringWithRange:NSMakeRange(1, [ip length] - 2)];
        }
    }
    return nil;
}

- (NSString * _Nullable)getIPV4 {
    NSString *ip = [self getIP];
    if (ip) {
        if ([ip hasPrefix:@"["] && [ip hasSuffix:@"]"]) {
            return nil;
        }
        return ip;
    }
    return nil;
}

//MARK: - Private

- (NSArray * _Nullable)getParts {
    NSString *colon = @":";
    NSRange firstColonRange = [self.address rangeOfString:colon];
    NSRange lastColonRange = [self.address rangeOfString:colon options:NSBackwardsSearch];
    NSString *lastPart = [self.address substringFromIndex:lastColonRange.location + lastColonRange.length];

    NSString *middlePart;
    if (firstColonRange.location != NSNotFound) {
        middlePart = [self.address substringFromIndex:firstColonRange.location + firstColonRange.length];
        //We need the range again as it's a relative position.
        lastColonRange = [middlePart rangeOfString:colon options:NSBackwardsSearch];
        if (lastColonRange.location != NSNotFound) {
            middlePart = [middlePart substringToIndex:lastColonRange.location];
        } else {
            return nil;
        }
    } else {
        return nil;
    }

    NSString *firstPart = [self.address substringWithRange: NSMakeRange(0, firstColonRange.location)];
    return @[firstPart, middlePart, lastPart];
}

- (NSString * _Nullable)getIP {
    NSMutableArray *parts = [[self getParts] mutableCopy];
    if (parts) {
        [parts removeObjectAtIndex:0];
        [parts removeLastObject];
        return [parts componentsJoinedByString:@""];
    }
    return nil;
}

@end
