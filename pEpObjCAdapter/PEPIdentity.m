//
//  PEPIdentity.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPIdentity.h"

#import "pEpEngine.h"
#import "PEPMessage.h"

@implementation PEPIdentity

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                            fingerPrint:(NSString * _Nullable)fingerPrint
                               commType:(PEP_comm_type)commType
                               language:(NSString * _Nullable)language {
    if (self = [super init]) {
        self.address = address;
        self.userID = userID;
        self.userName = userName;
        self.fingerPrint = fingerPrint;
        self.commType = commType;
        self.language = language;
    }
    return self;
}

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                            fingerPrint:(NSString * _Nullable)fingerPrint
{
    return [self initWithAddress:address userID:userID userName:userName fingerPrint:fingerPrint
                        commType:PEP_ct_unknown language:nil];
}

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
{
    return [self initWithAddress:address userID:userID userName:userName fingerPrint:nil
                        commType:PEP_ct_unknown language:nil];
}

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                               userName:(NSString * _Nullable)userName
{
    return [self initWithAddress:address userID:nil userName:userName fingerPrint:nil
                        commType:PEP_ct_unknown language:nil];
}

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
{
    return [self initWithAddress:address userID:nil userName:nil fingerPrint:nil
                        commType:PEP_ct_unknown language:nil];
}

- (nonnull instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithAddress:dictionary[kPepAddress] userID:dictionary[kPepUserID]
                        userName:dictionary[kPepUsername]
                     fingerPrint:dictionary[kPepFingerprint]
                        commType:[dictionary[kPepCommType] intValue]
                        language:dictionary[@"lang"]];
}

- (nonnull instancetype)initWithIdentity:(PEPIdentity * _Nonnull)identity
{
    return [self initWithAddress:identity.address userID:identity.userID
                        userName:identity.userName
                     fingerPrint:identity.fingerPrint
                        commType:identity.commType
                        language:identity.language];
}

- (PEPDict * _Nonnull)dictionary
{
    // most adapter use should be ok.
    return (PEPDict *) self;
}

- (PEPMutableDict * _Nonnull)mutableDictionary
{
    // most adapter use should be ok.
    return (PEPMutableDict *) self;
}

- (BOOL)containsPGPCommType
{
    PEP_comm_type val = (PEP_comm_type) self.commType;

    return
    val == PEP_ct_OpenPGP_weak_unconfirmed ||
    val == PEP_ct_OpenPGP_unconfirmed ||
    val == PEP_ct_OpenPGP_weak ||
    val == PEP_ct_OpenPGP;
}

- (BOOL)isConfirmed
{
    return self.commType & PEP_ct_confirmed;
}

// MARK: - Equality

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        return self.address == ((PEPIdentity *) other).address;
    }
}

- (NSUInteger)hash
{
    return self.address.hash;
}

// MARK: - NSKeyValueCoding

- (NSUInteger)comm_type
{
    return self.commType;
}

- (void)setComm_type:(PEP_comm_type)ct
{
    self.commType = ct;
}

- (NSString *)fpr
{
    return self.fingerPrint;
}

- (void)setFpr:(NSString *)fpr
{
    self.fingerPrint = fpr;
}

- (NSString *)user_id
{
    return self.userID;
}

- (void)setUser_id:(NSString *)uid
{
    self.userID = uid;
}

- (NSString *)username
{
    return self.userName;
}

- (void)setUsername:(NSString *)userName
{
    self.userName = userName;
}

- (NSString *)lang
{
    return self.language;
}

- (void)setLang:(NSString *)l
{
    self.language = l;
}

// MARK: - NSDictionary - Helpers

- (NSArray<NSArray<NSString *> *> *)keyValuePairs
{
    NSMutableArray *result = [@[ @[kPepAddress, self.address],
                                 @[kPepCommType,
                                   [NSNumber numberWithInteger:(NSInteger) self.commType]],
                                 @[kPepIsOwnIdentity, [NSNumber numberWithBool:self.isOwn]]]
                              mutableCopy];

    if (self.fingerPrint) {
        [result addObject:@[kPepFingerprint, self.fingerPrint]];
    }

    if (self.userID) {
        [result addObject:@[kPepUserID, self.userID]];
    }

    if (self.userName) {
        [result addObject:@[kPepUsername, self.userName]];
    }

    if (self.language) {
        [result addObject:@[@"lang", self.language]];
    }

    return result;
}

// MARK: - NSDictionary

- (nullable id)objectForKey:(NSString *)key
{
    return [self valueForKey:key];
}

- (NSInteger)count
{
    return [[self keyValuePairs] count];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    BOOL stop = NO;
    NSArray *pairs = [self keyValuePairs];
    for (NSArray *pair in pairs) {
        block(pair[0], pair[1], &stop);
        if (stop) {
            break;
        }
    }
}

// MARK: - NSMutableCopying

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    return [[PEPIdentity alloc] initWithAddress:self.address userID:self.userID
                                       userName:self.userName fingerPrint:self.fingerPrint
                                       commType:self.commType language:self.language];
}

- (NSString *)description
{
    return [NSString stringWithFormat:
            @"<PEPIdentity %@ userID:%@ userName:%@ fpr:%@ ct:%ld lang:%@>",
            self.address, self.userID, self.userName, self.fingerPrint,
            (long) self.commType, self.language];
}

@end
