//
//  PEPIdentity.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPSessionProtocol.h"
#import "PEPEngineTypes.h"

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

- (nonnull instancetype)initWithDictionary:(NSDictionary * _Nonnull)dictionary;

/**
 Copy constructor.
 */
- (nonnull instancetype)initWithIdentity:(PEPIdentity * _Nonnull)identity;

/**
 This method should be removed once the adapter fully supports objects for identity
 and message types insead of dictionaries.
 */
- (PEPDict * _Nonnull)dictionary;

/**
 This method should be removed once the adapter fully supports objects for identity
 and message types insead of dictionaries.
 */
- (PEPMutableDict * _Nonnull)mutableDictionary;

/**
 Is the given identity a pEp user, from the engine's point of view?
 */
- (NSNumber * _Nullable)isPEPUser:(PEPSession * _Nullable)session
                            error:(NSError * _Nullable * _Nullable)error;

/**
 Puts all properties into a default/nil state.
 */
- (void)reset;

/**
 Enables key sync on this identity.

 Will invoke the needed methods on an own session.

 @param error The usual cocoa error handling.
 @return The usual cocoa error handling.
 */
- (BOOL)enableKeySync:(NSError * _Nullable * _Nullable)error;

/**
 Disables key sync on this identity.

 Will invoke the needed methods on an own session.

 @param error The usual cocoa error handling.
 @return The usual cocoa error handling.
 */
- (BOOL)disableKeySync:(NSError * _Nullable * _Nullable)error;

/**
 Queries whether this own identity has key sync enabled or not.

 Will invoke the needed methods on an own session.

 @param error The usual cocoa error handling.
 @return A NSNumber denoting whether this own identity can participate in key sync enabled or not,
         or nil on error.
         YES means that key sync is allowed for this identity, otherwise it's NO.
 */
- (NSNumber * _Nullable)queryKeySyncEnabled:(NSError * _Nullable * _Nullable)error;

@end
