//
//  PEPIdentity.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <pEpObjCAdapterTypesHeaders/pEpObjCAdapterTypesHeaders.h>

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

- (BOOL)isConfirmed
{
    return self.commType & PEPCommTypeConfirmed;
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

@end
