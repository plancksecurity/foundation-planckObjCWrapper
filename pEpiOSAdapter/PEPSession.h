//
//  PEPSession.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 08.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "pEpiOSAdapter.h"
#import "PEPMessage.h"

@class PEPSession;

#pragma mark -- Constants

extern NSString *const kPepFrom;
extern NSString *const kPepTo;
extern NSString *const kPepShortMessage;
extern NSString *const kPepLongMessage;
extern NSString *const kPepOutgoing;
extern NSString *const kPepUsername;
extern NSString *const kPepAddress;
extern NSString *const kPepUserID;
extern NSString *const kPepFingerprint;
extern NSString *const kPepID;
extern NSString *const kPepSent;
extern NSString *const kPepReceived;
extern NSString *const kPepReceivedBy;
extern NSString *const kPepCC;
extern NSString *const kPepBCC;
extern NSString *const kPepReplyTo;
extern NSString *const kPepInReplyTo;
extern NSString *const kPepReferences;
extern NSString *const kPepOptFields;
extern NSString *const kPepLongMessageFormatted;
extern NSString *const kPepAttachments;
extern NSString *const kPepMimeData;
extern NSString *const kPepMimeFilename;
extern NSString *const kPepMimeType;
extern NSString *const kPepIsMe;

/** NSError parameters will use this domain */
extern NSString *const PEPSessionErrorDomain;

/** Callback type for doing something with a session */
typedef void (^PEPSessionBlock)(PEPSession *session);

@interface PEPSession : NSObject

#pragma mark -- Public API

/**
 Execute a block concurrently on a session.
 The session is created solely for execution of the block.
 */
+ (void)dispatchAsyncOnSession:(PEPSessionBlock)block;

/**
 Execute a block on a session and wait for it.
 The session is created solely for execution of the block.
 */
+ (void)dispatchSyncOnSession:(PEPSessionBlock)block;

/** Decrypt a message */
- (PEP_color)decryptMessage:(NSMutableDictionary *)src dest:(NSMutableDictionary **)dst keys:(NSArray **)keys;

/** Encrypt a message */
- (PEP_STATUS)encryptMessage:(NSMutableDictionary *)src extra:(NSArray *)keys dest:(NSMutableDictionary **)dst;

/** Determine the status color of a message to be sent */
- (PEP_color)outgoingMessageColor:(NSMutableDictionary *)msg;

/** Determine the status color of a message to be sent */
- (PEP_color)identityColor:(NSMutableDictionary *)identity;

/** Get trustwords for a fingerprint */
- (NSArray *)trustwords:(NSString *)fpr forLanguage:(NSString *)languageID shortened:(BOOL)shortened;

/**
 Supply an account used by our user himself. The identity is supplemented with the missing parts

 An identity is a `NSMutableDictionary` mapping a field name as `NSString` to different values.
 An identity can have the following fields (all other keys are ignored).
 It is not necessary to supply all fields; missing fields are supplemented by p≡p engine.
 
 @"username": real name or nick name (if pseudonymous) of identity
 @"address": URI or SMTP address
 @"user_id": persistent unique ID for identity
 @"lang": preferred languageID for communication with this ID (default: @"en")
 @"fpr": fingerprint of key to use for communication with this ID
 @"comm_type": communication type code (usually not needed)
 @"me": YES if this is an identity of our user, NO if it is one of a communication partner (default: NO)
 
 As an example:
 
 User has a mailbox. The mail address is "Dipul Khatri <dipul@inboxcube.com>". Then this would be:
 
 NSMutableDictionary *ident = [NSMutableDictionary dictionaryWithObjectsAndKeys:
 @"Dipul Khatri", @"username", @"dipul@inboxcube.com", @"address", 
 @"23", @"user_id", nil];
 
*/
- (void)mySelf:(NSMutableDictionary *)identity;

/**
 Supplement missing information for an arbitrary identity (used for communication partners).
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)updateIdentity:(NSMutableDictionary *)identity;

/**
 Mark a key as trusted with a person.
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)trustPersonalKey:(NSMutableDictionary *)identity;

/**
 if a key gets comprimized tell this using this message
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
 */
- (void)keyCompromized:(NSMutableDictionary *)identity;

/**
 Use this to undo keyCompromized or trustPersonalKey
 See `mySelf:(NSMutableDictionary *)identity` for an explanation of identities.
*/
- (void)keyResetTrust:(NSMutableDictionary*)identity;

#pragma mark -- Internal API (testing etc.)

/** For testing purpose, manual key import */
- (void)importKey:(NSString *)keydata;

- (void)resetPeptestHack;

@end
