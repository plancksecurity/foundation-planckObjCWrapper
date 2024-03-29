//
//  PEPIdentity.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPEngineTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity : NSObject <NSMutableCopying, NSSecureCoding>

/// The network address of this identity
@property (nonatomic) NSString *address;

/// The (optional) user ID.
@property (nonatomic, nullable) NSString *userID;

/// The (optional) user name.
@property (nonatomic, nullable) NSString *userName;

/// The (optional) fingerprint.
@property (nonatomic, nullable) NSString *fingerPrint;

/// The (optional) language that this identity uses.
@property (nonatomic, nullable) NSString *language;

/// The comm type of this identity.
@property PEPCommType commType;

/// Is this one of our own identities?
@property BOOL isOwn;

/// Flags controlling pEp sync behaviour, consisting of PEPIdentityFlags enums
/// ORed together.
@property int flags;

/// `major_ver` from `pEp_identity`
@property unsigned int majorVersion;

/// `minor_ver` from `pEp_identity`
@property unsigned int minorVersion;

/// `enc_format` from `pEp_identity`
@property PEPEncFormat encryptionFormat;

/// `flags` from `pEp_identity`
@property PEPIdentityFlags identityFlags;

- (nonnull instancetype)initWithAddress:(NSString *)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                                  isOwn:(BOOL)isOwn
                            fingerPrint:(NSString * _Nullable)fingerPrint
                               commType:(PEPCommType)commType
                               language:(NSString * _Nullable)language
                           majorVersion:(unsigned int)majorVersion
                           minorVersion:(unsigned int)minorVersion
                       encryptionFormat:(PEPEncFormat)encryptionFormat
                          identityFlags:(PEPIdentityFlags)identityFlags;

- (nonnull instancetype)initWithAddress:(NSString *)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                                  isOwn:(BOOL)isOwn
                            fingerPrint:(NSString * _Nullable)fingerPrint;

- (nonnull instancetype)initWithAddress:(NSString *)address
                                 userID:(NSString * _Nullable)userID
                               userName:(NSString * _Nullable)userName
                                  isOwn:(BOOL)isOwn;

- (nonnull instancetype)initWithAddress:(NSString *)address;

/// Copy constructor.
- (nonnull instancetype)initWithIdentity:(PEPIdentity *)identity;

@end

NS_ASSUME_NONNULL_END
