//
//  PEPIdentity.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPIdentity.h"

#import "pEpEngine.h"

#import "NSObject+Extension.h"

@implementation PEPIdentity

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                                  isOwn:(BOOL)isOwn
                            fingerPrint:(NSString * _Nullable)fingerPrint
                               commType:(PEPCommType)commType
                               language:(NSString * _Nullable)language {
    if (self = [super init]) {
        self.address = address;
        self.userID = userID;
        self.userName = userName;
        self.isOwn = isOwn;
        self.fingerPrint = fingerPrint;
        self.commType = commType;
        self.language = language;
    }
    return self;
}

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                                  isOwn:(BOOL)isOwn
                            fingerPrint:(NSString * _Nullable)fingerPrint
{
    return [self initWithAddress:address userID:userID userName:userName isOwn:isOwn
                     fingerPrint:fingerPrint commType:PEPCommTypeUnknown language:nil];
}

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                                  isOwn:(BOOL)isOwn
{
    return [self initWithAddress:address userID:userID userName:userName
                           isOwn:isOwn fingerPrint:nil commType:PEPCommTypeUnknown language:nil];
}

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
{
    return [self initWithAddress:address userID:nil userName:nil isOwn:NO fingerPrint:nil
                        commType:PEPCommTypeUnknown language:nil];
}

- (nonnull instancetype)initWithIdentity:(PEPIdentity * _Nonnull)identity
{
    return [self initWithAddress:identity.address userID:identity.userID
                        userName:identity.userName
                           isOwn:identity.isOwn
                     fingerPrint:identity.fingerPrint
                        commType:identity.commType
                        language:identity.language];
}

// MARK: - Equality

/**
 The keys that should be used to decide `isEqual` and compute the `hash`.
 */
static NSArray *s_keys;

- (BOOL)isEqualToPEPIdentity:(PEPIdentity * _Nonnull)identity
{
    return [self isEqualToObject:identity basedOnKeys:s_keys];
}

- (NSUInteger)hash
{
    return [self hashBasedOnKeys:s_keys];
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }

    return [self isEqualToPEPIdentity:object];
}

// MARK: - NSMutableCopying

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return [[PEPIdentity alloc] initWithAddress:self.address userID:self.userID
                                       userName:self.userName isOwn:self.isOwn
                                    fingerPrint:self.fingerPrint
                                       commType:self.commType language:self.language];
}

// MARK: - Debug

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"<PEPIdentity %@ userID:%@ userName:%@ isOwn:%d fpr:%@ ct:%ld lang:%@>",
            self.address, self.userID, self.userName, self.isOwn, self.fingerPrint,
            (long) self.commType, self.language];
}

// MARK: - Static Initialization

+ (void)initialize
{
    s_keys = @[@"address"];
}

// MARK: - NSSecureCoding

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
