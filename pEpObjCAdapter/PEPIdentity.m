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
                               commType:(NSInteger)commType
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

- (void)setComm_type:(NSUInteger)ct
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

// MARK: - NSDictionary

- (nullable id)objectForKey:(NSString *)key
{
    return [self valueForKey:key];
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
