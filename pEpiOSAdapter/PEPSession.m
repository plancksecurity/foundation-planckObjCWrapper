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

NSString *const kPepFrom = @"from";
NSString *const kPepTo = @"to";
NSString *const kPepShortMessage = @"shortmsg";
NSString *const kPepLongMessage = @"longmsg";
NSString *const kPepOutgoing = @"outgoing";
NSString *const kPepUsername = @"username";
NSString *const kPepAddress = @"address";
NSString *const kPepUserID = @"user_id";
NSString *const kPepFingerprint = @"fpr";
NSString *const kPepID = @"id";
NSString *const kPepSent = @"sent";
NSString *const kPepReceived = @"recv";
NSString *const kPepReceivedBy = @"recv_by";
NSString *const kPepCC = @"cc";
NSString *const kPepBCC = @"bcc";
NSString *const kPepReplyTo = @"reply_to";
NSString *const kPepInReplyTo = @"in_reply_to";
NSString *const kPepReferences = @"references";
NSString *const kPepOptFields = @"opt_fields";
NSString *const kPepLongMessageFormatted = @"longmsg_formatted";
NSString *const kPepAttachments = @"attachments";
NSString *const kPepMimeData = @"data";
NSString *const kPepMimeFilename = @"filename";
NSString *const kPepMimeType = @"mimeType";
NSString *const kPepIsMe = @"me";

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

    @synchronized (self) {
        decrypt_message(_session, _src, &_dst, &_keys, &color);
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

- (PEP_STATUS)encryptMessageDict:(NSDictionary *)src extra:(NSArray *)keys dest:(NSDictionary **)dst
{
    PEP_STATUS status;
    message * _src = PEP_messageDictToStruct(src);
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

- (PEP_color)outgoingMessageColor:(NSMutableDictionary *)msg
{
    message * _msg = PEP_messageDictToStruct(msg);
    PEP_color color = PEP_rating_undefined;

    @synchronized (self) {
        outgoing_message_color(_session, _msg, &color);
    }

    free_message(_msg);
    
    return color;
}

- (PEP_color)identityColor:(NSMutableDictionary *)identity
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

- (void)trustPersonalKey:(NSMutableDictionary *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);
    
    @synchronized(self) {
        trust_personal_key(_session, ident);
    }
    
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)keyResetTrust:(NSMutableDictionary *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);
    
    @synchronized(self) {
        key_reset_trust(_session, ident);
    }
    
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)keyCompromized:(NSMutableDictionary *)identity
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
        import_key(_session, [keydata UTF8String], [keydata length]);
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
