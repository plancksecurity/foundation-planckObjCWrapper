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

@interface PEPSession : NSObject

// creates a PEPSession

+ (PEPSession *)session;

// decrypt a message

- (PEP_color)decryptMessage:(NSMutableDictionary *)src dest:(NSMutableDictionary **)dst keys:(NSArray **)keys;

// encrypt a message

- (PEP_STATUS)encryptMessage:(NSMutableDictionary *)src extra:(NSArray *)keys dest:(NSMutableDictionary **)dst;

// message is to be sent

- (PEP_color)outgoingMessageColor:(NSMutableDictionary *)msg;

// get trustwords for a fingerprint

- (NSArray *)trustwords:(NSString *)fpr forLanguage:(NSString *)languageID shortened:(BOOL)shortened;

/*
 
 An identity is a NSMutableDictionary mapping a field name as NSString to different values.
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

// supply an account used by our user himself
// the identity is supplemented with the missing parts

- (void)mySelf:(NSMutableDictionary *)identity;

// supplement missing information for an arbitrary identity (used for communication partners)

- (void)updateIdentity:(NSMutableDictionary *)identity;

//  mark a key as trusted with a person

- (void)trustPersonalKey:(NSMutableDictionary *)identity;

// if a key gets comprimized tell this using this message

- (void)keyCompromized:(NSMutableDictionary *)identity;

// use this to undo keyCompromized or trustPersonalKey

- (void)keyResetTrust:(NSMutableDictionary*)identity;

// for testing purpose, manual key import

- (void)importKey:(NSString *)keydata;

@end
