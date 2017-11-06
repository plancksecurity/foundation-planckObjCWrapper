//
//  PEPIdentity.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEPIdentity : NSObject <NSMutableCopying>

/**
 The network address of this identity
 */
@property (nonatomic, nonnull) NSString *address;

/**
 The (optional) user ID.
 */
@property (nonatomic, nullable) NSString *userID;

/**
 The (optional) user name.
 */
@property (nonatomic, nullable) NSString *userName;

/**
 The (optional) fingerprint.
 */
@property (nonatomic, nullable) NSString *fingerPrint;

/**
 The (optional) language that this identity uses.
 */
@property (nonatomic, nullable) NSString *language;

/**
 The comm type of this identity.
 */
@property NSInteger commType;

/**
 Is this one of our own identities?
 */
@property BOOL isOwn;

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                            fingerPrint:(NSString * _Nullable)fingerPrint
                               commType:(NSInteger)commType
                               language:(NSString * _Nullable)language;

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                            fingerPrint:(NSString * _Nullable)fingerPrint;

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName;

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                               userName:(NSString * _Nullable)userName;

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address;

- (nonnull instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Does this identity contain a PGP comm type? This can be used for determining
 if a communication partner is a pEp user or not.
 */
- (BOOL)containsPGPCommType;

@end
