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
                                scheme:(NSString *)scheme
                                  ipV4:(NSString *)ipV4
                                  port:(NSUInteger)port
{
    if (self = [super init]) {
        self.userID = userID;
        self.address = [NSString stringWithFormat:IPV4Format, scheme, ipV4, (unsigned long) port];
    }
    return self;
}

- (nonnull instancetype)initWithUserID:(NSString *)userID
                                scheme:(NSString *)scheme
                                  ipV6:(NSString *)ipV6
                                  port:(NSUInteger)port
{
    if (self = [super init]) {
        self.userID = userID;
        self.address = [NSString stringWithFormat:IPV6Format, scheme, ipV6, (unsigned long) port];
    }
    return self;
}

- (NSString * _Nullable)getScheme {
    NSArray *parts = [self getParts];
    if (parts) {
        return [parts firstObject];
    }
    return nil;
}

- (NSNumber * _Nullable)getPort {
    NSArray *parts = [self getParts];
    if (parts.count == 3) {
        return @([[parts lastObject] intValue]);
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
    //No colon, no parts.

    if (firstColonRange.location == NSNotFound || lastColonRange.location == NSNotFound || firstColonRange.location == lastColonRange.location) {
        return nil;
    }
    //Get the last part
    NSString *lastPart = [self.address substringFromIndex:lastColonRange.location + lastColonRange.length];

    //Get the middle part.
    NSRange middleRange = NSMakeRange(firstColonRange.location + firstColonRange.length , lastColonRange.location - firstColonRange.location - lastColonRange.length);
    NSString *middlePart = [self.address substringWithRange:middleRange];

    //Get the first part
    NSString *firstPart = [self.address substringWithRange: NSMakeRange(0, firstColonRange.location)];
    return @[firstPart, middlePart, lastPart];
}

- (NSString * _Nullable)getIP {
    NSMutableArray *parts = [[self getParts] mutableCopy];
    if (parts.count == 3) {
        [parts removeObjectAtIndex:0];
        [parts removeLastObject];
        return [parts componentsJoinedByString:@""];
    }
    return nil;
}

@end
