//
//  PEPIdentity.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#ifndef PEPIdentity_h
#define PEPIdentity_h

#import <Foundation/Foundation.h>

#ifdef FRAMEWORK_BUILD
#import <PEPObjCAdapterTypesFramework/PEPCommType.h>
#else
#import "PEPCommType.h"
#endif

@class PEPSession;

@interface PEPIdentity : NSObject <NSMutableCopying>

/**
 The network address of this identity
 */
@property (nonatomic, nonnull) NSString *address;

/**
 The user ID.
 */
@property (nonatomic, nonnull) NSString *userID;

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
@property PEPCommType commType;

/**
 Is this one of our own identities?
 */
@property BOOL isOwn;

/// Flags controlling pEp sync behaviour, consisting of PEPIdentityFlags enums
/// ORed together.
@property int flags;

/**
 Comm type contains the PEP_ct_confirmed flag?
 */
@property (readonly) BOOL isConfirmed;

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                                  isOwn:(BOOL)isOwn
                            fingerPrint:(NSString * _Nullable)fingerPrint
                               commType:(PEPCommType)commType
                               language:(NSString * _Nullable)language;

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                                  isOwn:(BOOL)isOwn
                            fingerPrint:(NSString * _Nullable)fingerPrint;

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                                  isOwn:(BOOL)isOwn;

- (nonnull instancetype)initWithAddress:(NSString * _Nonnull)address;

/**
 Copy constructor.
 */
- (nonnull instancetype)initWithIdentity:(PEPIdentity * _Nonnull)identity;

@end

#endif
