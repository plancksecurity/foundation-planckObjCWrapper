//
//  PEPIdentity+SecureCoding.m
//  pEpObjCAdapter
//
//  Created by David Alarcon on 25/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPIdentity+SecureCoding.h"

@implementation PEPIdentity (SecureCoding)

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.address        forKey:@"address"];
    [coder encodeObject:self.userID         forKey:@"userID"];
    [coder encodeObject:self.userName       forKey:@"userName"];
    [coder encodeObject:self.fingerPrint    forKey:@"fingerPrint"];
    [coder encodeObject:self.language       forKey:@"language"];
    [coder encodeInt:self.commType          forKey:@"commType"];
    [coder encodeBool:self.isOwn            forKey:@"isOwn"];
    [coder encodeInt:self.flags             forKey:@"flags"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder {
    if (self = [self init]) {
        self.address = [decoder decodeObjectOfClass:[NSString class] forKey:@"address"];
        self.userID = [decoder decodeObjectOfClass:[NSString class] forKey:@"userID"];
        self.userName = [decoder decodeObjectOfClass:[NSString class] forKey:@"userName"];
        self.fingerPrint = [decoder decodeObjectOfClass:[NSString class] forKey:@"fingerPrint"];
        self.language = [decoder decodeObjectOfClass:[NSString class] forKey:@"language"];
        self.commType = [decoder decodeIntForKey:@"commType"];
        self.isOwn = [decoder decodeBoolForKey:@"isOwn"];
        self.flags = [decoder decodeIntForKey:@"flags"];
    }

    return self;
}

+ (BOOL)supportsSecureCoding {
    return  YES;
}

@end
