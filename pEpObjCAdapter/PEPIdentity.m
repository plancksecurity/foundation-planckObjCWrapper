//
//  PEPIdentity.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPIdentity.h"
#import "PEPConstants.h"

#import "pEpEngine.h"
#import "PEPMessageUtil.h"
#import "PEPSession.h"
#import "PEPMessageUtil.h"

#import "NSObject+Extension.h"

@interface PEPIdentity ()

@property (nonatomic) identity_flags_t flags;

@end

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

- (nonnull instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithAddress:dictionary[kPepAddress] userID:dictionary[kPepUserID]
                        userName:dictionary[kPepUsername]
                           isOwn:[dictionary[kPepIsOwnIdentity] boolValue]
                     fingerPrint:dictionary[kPepFingerprint]
                        commType:[dictionary[kPepCommType] intValue]
                        language:dictionary[@"lang"]];
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

// MARK: API

- (NSNumber * _Nullable)isPEPUser:(PEPSession * _Nullable)session
                            error:(NSError * _Nullable * _Nullable)error
{
    if (!session) {
        session = [PEPSession new];
    }
    return [session isPEPUser:self error:error];
}

- (BOOL)isConfirmed
{
    return self.commType & PEP_ct_confirmed;
}

- (BOOL)queryKeySyncEnabled:(BOOL * _Nonnull)enabled
                    session:(PEPSession * _Nonnull)session
                      error:(NSError * _Nullable * _Nullable)error
{
    BOOL success = [session updateIdentity:self error:error];

    if (!success) {
        return NO;
    }

    *enabled = self.flags & PEP_idf_not_for_sync;

    return YES;
}

- (BOOL)enableKeySync:(BOOL)enabled
              session:(PEPSession * _Nonnull)session
                error:(NSError * _Nullable * _Nullable)error
{
    BOOL success = [session updateIdentity:self error:error];

    if (!success) {
        return NO;
    }

    identity_flags theFlags = self.flags;
    theFlags = theFlags || PEP_idf_not_for_sync;

    return [session setFlags:(PEPIdentityFlags) theFlags forIdentity:self error:error];
}

// MARK: Faking directory

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

// MARK: - NSKeyValueCoding

- (NSUInteger)comm_type
{
    return self.commType;
}

- (void)setComm_type:(PEPCommType)ct
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

- (void)reset
{
    self.commType = PEP_ct_unknown;
    self.language = nil;
    self.fingerPrint = nil;
    self.userID = nil;
    self.userName = nil;
    self.isOwn = NO;
    self.flags = 0;
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

@end
