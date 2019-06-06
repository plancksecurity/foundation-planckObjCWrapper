//
//  PEPConstants.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 01.03.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Constants

/** The name of the user */
extern NSString *const _Nonnull kPepUsername;

/** Email address of the contact */
extern NSString *const _Nonnull kPepAddress;

/**
 A user ID, used by pEp to map multiple identities to a single user.
 This should be a stable ID.
 pEp identities set up with mySelf() get a special user ID.
 */
extern NSString *const _Nonnull kPepUserID;

/**
 Dict key for value isOwn/me.
 isOwn indicates the identity is representing me.
 */
extern NSString *const _Nonnull kPepIsOwn;

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

/** The key of the header for certain sync messages, "pEp-auto-consume". */
extern NSString *const _Nonnull kPepHeaderAutoConsume;

/** The positive value of the header for "pEp-auto-consume". */
extern NSString *const _Nonnull kPepValueAutoConsumeYes;
