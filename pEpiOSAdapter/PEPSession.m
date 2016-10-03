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

- (PEP_rating)decryptMessageDict:(nonnull NSDictionary *)src
                            dest:(NSDictionary * _Nullable * _Nullable)dst
                            keys:(NSArray * _Nullable * _Nullable)keys
{
    message * _src = PEP_messageDictToStruct(src);
    message * _dst = NULL;
    stringlist_t * _keys = NULL;
    PEP_rating color = PEP_rating_undefined;
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

    if (dst) {
        *dst = dst_;
    }
    if (keys) {
        *keys = keys_;
    }
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

- (PEP_STATUS)encryptMessageDict:(nonnull NSDictionary *)src
                           extra:(nullable NSArray *)keys
                            dest:(NSDictionary * _Nullable * _Nullable)dst
{
    PEP_STATUS status;
    PEP_encrypt_flags_t flags;

    message * _src = PEP_messageDictToStruct([self removeEmptyRecipients:src]);
    message * _dst = NULL;
    stringlist_t * _keys = PEP_arrayToStringlist(keys);

    @synchronized (self) {
        status = encrypt_message(_session, _src, _keys, &_dst, PEP_enc_PGP_MIME, flags);
    }

    NSDictionary * dst_;

    if (_dst) {
        dst_ = PEP_messageDictFromStruct(_dst);
    }
    else {
        dst_ = PEP_messageDictFromStruct(_src);
    }
    if (dst) {
        *dst = dst_;
    }

    free_message(_src);
    free_message(_dst);
    free_stringlist(_keys);
    
    return status;
}

- (PEP_STATUS)encryptMessageDict:(nonnull NSDictionary *)src
                        identity:(nonnull NSDictionary *)identity
                            dest:(NSDictionary * _Nullable * _Nullable)dst
{
    PEP_STATUS status;

    message * _src = PEP_messageDictToStruct([self removeEmptyRecipients:src]);
    pEp_identity *ident = PEP_identityDictToStruct(identity);
    message * _dst = NULL;

    @synchronized (self) {
        status = encrypt_message_for_self(_session, ident, _src, &_dst, PEP_enc_PGP_MIME);
    }

    NSDictionary * dst_;

    if (_dst) {
        dst_ = PEP_messageDictFromStruct(_dst);
    }
    else {
        dst_ = PEP_messageDictFromStruct(_src);
    }

    if (dst) {
        *dst = dst_;
    }

    free_message(_src);
    free_message(_dst);
    free_identity(ident);

    return status;
}

- (PEP_rating)outgoingMessageColor:(NSDictionary *)msg
{
    message * _msg = PEP_messageDictToStruct(msg);
    PEP_rating color = PEP_rating_undefined;

    @synchronized (self) {
        outgoing_message_rating(_session, _msg, &color);
    }

    free_message(_msg);
    
    return color;
}

- (PEP_rating)identityColor:(NSDictionary *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);
    PEP_rating color = PEP_rating_undefined;
    
    @synchronized (self) {
        identity_rating(_session, ident, &color);
    }
    
    free_identity(ident);
    
    return color;
}

DYNAMIC_API PEP_STATUS identity_rating(
                                      PEP_SESSION session,
                                      pEp_identity *ident,
                                      PEP_rating *color
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

- (void)keyMistrusted:(NSMutableDictionary *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);
    
    @synchronized(self) {
        key_mistrusted(_session, ident);
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

- (PEP_rating)outgoingColorFrom:(nonnull NSDictionary *)from
                            to:(nonnull NSDictionary *)to
{
    NSMutableDictionary *mTo = to.mutableCopy;
    [self updateIdentity:mTo];
    NSMutableDictionary *mFrom = from.mutableCopy;
    [self mySelf:mFrom];

    NSMutableDictionary *fakeMail = [NSMutableDictionary dictionary];
    fakeMail[kPepFrom] = mFrom;
    fakeMail[kPepOutgoing] = @YES;
    fakeMail[kPepTo] = @[mTo];
    fakeMail[kPepShortMessage] = @"Some fake subject";
    fakeMail[kPepLongMessage] = @"Some fake long message";
    PEP_rating color = [self outgoingMessageColor:fakeMail];
    return color;
}

@end
