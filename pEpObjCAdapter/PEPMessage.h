//
//  MCOAbstractMessage+PEPMessage.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 09.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "message_api.h"

@class PEPIdentity;

NSArray * _Nonnull PEP_arrayFromStringlist(stringlist_t * _Nonnull sl);
stringlist_t * _Nullable PEP_arrayToStringlist(NSArray * _Nullable array);

pEp_identity * _Nonnull PEP_identityToStruct(PEPIdentity * _Nonnull identity);

/**
 If the ident does not contain an address, no PEPIdentity can be constructed.
 */
PEPIdentity * _Nullable PEP_identityFromStruct(pEp_identity * _Nonnull ident);

pEp_identity * _Nullable PEP_identityDictToStruct(NSDictionary * _Nullable dict);
NSDictionary * _Nonnull PEP_identityDictFromStruct(pEp_identity * _Nullable ident);

message * _Nullable PEP_messageDictToStruct(NSDictionary * _Nullable dict);
NSDictionary * _Nonnull PEP_messageDictFromStruct(message * _Nullable msg);

#pragma mark -- Constants

/** The name of the user */
extern NSString *const _Nonnull kPepUsername;

/** Email address of the contact */
extern NSString *const _Nonnull kPepAddress;

/**
 A user ID, used by pEp to map multiple identities to a single user.
 This should be a stable ID (e.g. derived from the address book if possible).
 pEp identities set up with mySelf() get a special user ID.
 */
extern NSString *const _Nonnull kPepUserID;

/** The fingerprint for the key for this contact. */
extern NSString *const _Nonnull kPepFingerprint;

/** In an email, the identity this email is from */
extern NSString *const _Nonnull kPepFrom;

/** In an email, the `NSArray` of to recipients */
extern NSString *const _Nonnull kPepTo;

/** In an email, the `NSArray` of CC recipients */
extern NSString *const _Nonnull kPepCC;

/** In an email, the `NSArray` of BCC recipients */
extern NSString *const _Nonnull kPepBCC;

/** The subject of an email */
extern NSString *const _Nonnull kPepShortMessage;

/** The text message of an email */
extern NSString *const _Nonnull kPepLongMessage;

/** HTML message part, if any */
extern NSString *const _Nonnull kPepLongMessageFormatted;

/** NSNumber denoting a boolean. True if that message is supposed to be sent. */
extern NSString *const _Nonnull kPepOutgoing;

/** Sent date of the message (NSDate) */
extern NSString *const _Nonnull kPepSent;

/** Received date of the message (NSDate) */
extern NSString *const _Nonnull kPepReceived;

/** The message ID */
extern NSString *const _Nonnull kPepID;

extern NSString *const _Nonnull kPepReceivedBy;
extern NSString *const _Nonnull kPepReplyTo;
extern NSString *const _Nonnull kPepInReplyTo;
extern NSString *const _Nonnull kPepReferences;
extern NSString *const _Nonnull kPepKeywords;
extern NSString *const _Nonnull kPepOptFields;

/** NSArray of attachment dicts */
extern NSString *const _Nonnull kPepAttachments;

/** The binary NSData representing the content of an attachment */
extern NSString *const _Nonnull kPepMimeData;

/** The NSString filename of an attachment, if any */
extern NSString *const _Nonnull kPepMimeFilename;

/** The mime type of an attachment */
extern NSString *const _Nonnull kPepMimeType;

/** The pEp internal communication type */
extern NSString *const _Nonnull kPepCommType;

/** The raw message created by pEp (NSData) */
extern NSString *const _Nonnull kPepRawMessage;

/** NSError parameters will use this domain */
extern NSString *const _Nonnull PEPSessionErrorDomain;

/** Optional field "X-pEp-Version" */
extern NSString *const _Nonnull kXpEpVersion;

/** Optional field "X-EncStatus" */
extern NSString *const _Nonnull kXEncStatus;

/** Optional field "X-KeyList" */
extern NSString *const _Nonnull kXKeylist;

/** Key for the boolean flag that denotes own identities */
extern NSString *const _Nonnull kPepIsOwnIdentity;
