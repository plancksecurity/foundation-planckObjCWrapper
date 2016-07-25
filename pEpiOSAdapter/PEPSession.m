//
//  PEPSession.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 08.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "PEPSession.h"
#import "pEpiOSAdapter.h"
#import "PEPIOSAdapter+Internal.h"
#import "PEPMessage.h"

#pragma mark -- Constants

/** The name of the user */
NSString *const kPepUsername = @"username";

/** Email address of the contact */
NSString *const kPepAddress = @"address";

/**
 A user ID, used by pEp to map multiple identities to a single user.
 This should be a stable ID (e.g. derived from the address book if possible).
 pEp identities set up with mySelf() get a special user ID.
 */
NSString *const kPepUserID = @"user_id";

/** The fingerprint for the key for this contact. */
NSString *const kPepFingerprint = @"fpr";

/** NSNumber denoting a boolean, true if that identity was setup with mySelf() */
NSString *const kPepIsMe = @"me";

/** In an email, the identity this email is from */
NSString *const kPepFrom = @"from";

/** In an email, the `NSArray` of to recipients */
NSString *const kPepTo = @"to";

/** In an email, the `NSArray` of CC recipients */
NSString *const kPepCC = @"cc";

/** In an email, the `NSArray` of BCC recipients */
NSString *const kPepBCC = @"bcc";

/** The subject of an email */
NSString *const kPepShortMessage = @"shortmsg";

/** The text message of an email */
NSString *const kPepLongMessage = @"longmsg";

/** HTML message part, if any */
NSString *const kPepLongMessageFormatted = @"longmsg_formatted";

/** NSNumber denoting a boolean. True if that message is supposed to be sent. */
NSString *const kPepOutgoing = @"outgoing";

/** NSDate (sent date) */
NSString *const kPepSent = @"sent";

/** NSDate (received date) */

NSString *const kPepReceived = @"recv";

/** The message ID */
NSString *const kPepID = @"id";

NSString *const kPepReceivedBy = @"recv_by";
NSString *const kPepReplyTo = @"reply_to";
NSString *const kPepInReplyTo = @"in_reply_to";
NSString *const kPepReferences = @"references";
NSString *const kPepOptFields = @"opt_fields";

/** NSArray of attachment dicts */
NSString *const kPepAttachments = @"attachments";

/** The binary NSData representing the content of an attachment */
NSString *const kPepMimeData = @"data";

/** The NSString filename of an attachment, if any */
NSString *const kPepMimeFilename = @"filename";

/** The mime type of an attachment */
NSString *const kPepMimeType = @"mimeType";

/** The pEp internal communication type */
NSString *const kPepCommType = @"comm_type";

@interface PEPSession ()

@property (nonatomic) PEP_SESSION session;

@end

@implementation PEPSession


// serialize all session access
+ (dispatch_queue_t)sharedSessionQueue
{
    static dispatch_once_t once;
    static dispatch_queue_t sharedSessionQueue;
    dispatch_once(&once, ^{
        sharedSessionQueue = dispatch_queue_create("pEp session queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return sharedSessionQueue;
}

+ (PEPSession *)session
{
    PEPSession *_session = [[PEPSession alloc] init];
    return _session;
}

+ (void)dispatchAsyncOnSession:(PEPSessionBlock)block
{
    dispatch_async([self sharedSessionQueue], ^{
        PEPSession *pepSession = [[PEPSession alloc] init];
        block(pepSession);
    });
}

+ (void)dispatchSyncOnSession:(PEPSessionBlock)block
{
    PEPSession *pepSession = [[PEPSession alloc] init];
    block(pepSession);
}

+ (void)setupTrustWordsDB
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [PEPiOSAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];
    });
}

- (id)init
{
    [PEPSession setupTrustWordsDB];

    PEP_STATUS status = init(&_session);

    if (status != PEP_STATUS_OK) {
        return nil;
    }
    
    [PEPiOSAdapter registerExamineFunction:_session];
    return self;
}

- (void)dealloc
{
    release(_session);
}

- (PEP_color)decryptMessageDict:(NSDictionary *)src dest:(NSDictionary **)dst keys:(NSArray **)keys
{
    message * _src = PEP_messageDictToStruct(src);
    message * _dst = NULL;
    stringlist_t * _keys = NULL;
    PEP_color color = PEP_rating_undefined;
    PEP_decrypt_flags_t flags = 0;

    @synchronized (self) {
        decrypt_message(_session, _src, &_dst, &_keys, &color, &flags);
    }

    NSDictionary * dst_;

    if (_dst) {
        dst_ = PEP_messageDictFromStruct(_dst);
    }
    else {
        dst_ = PEP_messageDictFromStruct(_src);
    }

    NSArray * keys_ = nil;
    if (_keys)
        keys_ = PEP_arrayFromStringlist(_keys);

    free_message(_src);
    free_message(_dst);
    free_stringlist(_keys);

    *dst = dst_;
    *keys = keys_;
    return color;
}

- (void)removeEmptyArrayKey:(NSString *)key inDict:(NSMutableDictionary *)dict
{
    if ([[dict objectForKey:key] count] == 0) {
        [dict removeObjectForKey:key];
    }
}

- (NSDictionary *)removeEmptyRecipients:(NSDictionary *)src
{
    NSMutableDictionary *dest = src.mutableCopy;

    [self removeEmptyArrayKey:kPepTo inDict:dest];
    [self removeEmptyArrayKey:kPepCC inDict:dest];
    [self removeEmptyArrayKey:kPepBCC inDict:dest];

    return [NSDictionary dictionaryWithDictionary:dest];
}

- (PEP_STATUS)encryptMessageDict:(NSDictionary *)src extra:(NSArray *)keys dest:(NSDictionary **)dst
{
    PEP_STATUS status;
    message * _src = PEP_messageDictToStruct([self removeEmptyRecipients:src]);
    message * _dst = NULL;
    stringlist_t * _keys = PEP_arrayToStringlist(keys);

    @synchronized (self) {
        status = encrypt_message(_session, _src, _keys, &_dst, PEP_enc_PGP_MIME);
    }

    NSDictionary * dst_;

    if (_dst) {
        dst_ = PEP_messageDictFromStruct(_dst);
    }
    else {
        dst_ = PEP_messageDictFromStruct(_src);
    }
    *dst = dst_;

    free_message(_src);
    free_message(_dst);
    free_stringlist(_keys);
    
    return status;
}

- (PEP_color)outgoingMessageColor:(NSDictionary *)msg
{
    message * _msg = PEP_messageDictToStruct(msg);
    PEP_color color = PEP_rating_undefined;

    @synchronized (self) {
        outgoing_message_color(_session, _msg, &color);
    }

    free_message(_msg);
    
    return color;
}

- (PEP_color)identityColor:(NSDictionary *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);
    PEP_color color = PEP_rating_undefined;
    
    @synchronized (self) {
        identity_color(_session, ident, &color);
    }
    
    free_identity(ident);
    
    return color;
}

DYNAMIC_API PEP_STATUS identity_color(
                                      PEP_SESSION session,
                                      pEp_identity *ident,
                                      PEP_color *color
                                      );


- (NSArray *)trustwords:(NSString *)fpr forLanguage:(NSString *)languageID shortened:(BOOL)shortened
{
    NSMutableArray *array = [NSMutableArray array];

    for (int i = 0; i < [fpr length]; i += 4) {
        if (shortened && i >= 20)
            break;
        
        NSString *str = [fpr substringWithRange:NSMakeRange(i, 4)];

        unsigned int value;
        [[NSScanner scannerWithString:str] scanHexInt:&value];
        
        char *word;
        size_t size;

        @synchronized (self) {
            trustword(_session, value, [languageID UTF8String], &word, &size);
        }

        [array addObject:[NSString stringWithUTF8String:word]];
        free(word);
    }
    
    return array;
}

- (void)mySelf:(NSMutableDictionary *)identity
{
    [identity removeObjectForKey:kPepUserID];

    pEp_identity *ident = PEP_identityDictToStruct(identity);

    @synchronized(self) {
        myself(_session, ident);
    }

    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)updateIdentity:(NSMutableDictionary *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);

    @synchronized(self) {
        update_identity(_session, ident);
    }

    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)trustPersonalKey:(NSDictionary *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);
    
    @synchronized(self) {
        trust_personal_key(_session, ident);
    }
    
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)keyResetTrust:(NSDictionary *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);
    
    @synchronized(self) {
        key_reset_trust(_session, ident);
    }
    
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)keyCompromized:(NSDictionary *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);
    
    @synchronized(self) {
        key_compromized(_session, ident);
    }
    
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)importKey:(NSString *)keydata
{
    @synchronized(self) {
        import_key(_session, [keydata UTF8String], [keydata length], NULL);
    }

}

- (void)resetPeptestHack
{
    reset_peptest_hack(_session);
}

- (void)logTitle:(nonnull NSString *)title entity:(nonnull NSString *)entity
     description:(nullable NSString *)description comment:(nullable NSString *)comment
{
    log_event(self.session, [[title precomposedStringWithCanonicalMapping] UTF8String],
              [[entity precomposedStringWithCanonicalMapping] UTF8String],
              [[description precomposedStringWithCanonicalMapping] UTF8String],
              [[comment precomposedStringWithCanonicalMapping] UTF8String]);
}

- (nonnull NSString *)getLog
{
    char *data;
    get_crashdump_log(self.session, 0, &data);
    NSString *logString = [NSString stringWithUTF8String:data];
    return logString;
}

@end
