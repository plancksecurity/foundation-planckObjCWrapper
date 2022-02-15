//
//  PEPIdentity.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPIdentity.h"
#import "PEPEqualableTools.h"

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

- (NSUInteger)hash
{
    return [PEPEqualableTools hashForObject:self basedOnKeys:s_keys];
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

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.userID forKey:@"userID"];
    [coder encodeObject:self.userName forKey:@"userName"];
    [coder encodeObject:self.fingerPrint forKey:@"fingerPrint"];
    [coder encodeObject:self.language forKey:@"language"];
    [coder encodeInt:self.commType forKey:@"commType"];
    [coder encodeBool:self.isOwn forKey:@"isOwn"];
    [coder encodeInt:self.flags forKey:@"flags"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

// MARK: - Equality

/// Determine if the object passed by param is the same identity.
///
/// @see isEqual as it calls it internally.
/// @param object The object to compare.
/// @return YES if it's the same identity. Otherwise it returns NO.
- (BOOL)isEqualTo:(id)object
{
    return [self isEqual:object];
}

/// Determine if the object passed by param is the same identity.
/// If the param is an identitiy and both identities have no address will be considered equal.
/// Address comparison is case-insensitive.

/// @param object The object to compare.
/// @return YES if it's the same identity. Otherwise it returns NO.
- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[PEPIdentity class]]) {
        NSString *key = @"address";
        NSString *selfAddress = (NSString *) [self valueForKey:key];
        NSString *otherAddress = (NSString *) [object valueForKey:key];
        return [selfAddress caseInsensitiveCompare:otherAddress] == NSOrderedSame;
    }
    return NO;
}

@end
