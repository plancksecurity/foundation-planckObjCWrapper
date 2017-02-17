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

- (PEP_rating)decryptMessageDict:(nonnull NSDictionary<NSString *, id> *)src
                            dest:(NSDictionary<NSString *, id> * _Nullable * _Nullable)dst
                            keys:(NSArray<NSString *> * _Nullable * _Nullable)keys
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

- (void)removeEmptyArrayKey:(NSString *)key inDict:(NSMutableDictionary<NSString *, id> *)dict
{
    if ([[dict objectForKey:key] count] == 0) {
        [dict removeObjectForKey:key];
    }
}

- (NSDictionary *)removeEmptyRecipients:(NSDictionary<NSString *, id> *)src
{
    NSMutableDictionary *dest = src.mutableCopy;

    [self removeEmptyArrayKey:kPepTo inDict:dest];
    [self removeEmptyArrayKey:kPepCC inDict:dest];
    [self removeEmptyArrayKey:kPepBCC inDict:dest];

    return [NSDictionary dictionaryWithDictionary:dest];
}

- (PEP_STATUS)encryptMessageDict:(nonnull NSDictionary<NSString *, id> *)src
                           extra:(nullable NSArray *)keys
                            dest:(NSDictionary<NSString *, id> * _Nullable * _Nullable)dst
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

- (PEP_STATUS)encryptMessageDict:(nonnull NSDictionary<NSString *, id> *)src
                        identity:(nonnull NSDictionary<NSString *, id> *)identity
                            dest:(NSDictionary<NSString *, id> * _Nullable * _Nullable)dst
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

- (PEP_rating)outgoingMessageColor:(NSDictionary<NSString *, id> *)msg
{
    message * _msg = PEP_messageDictToStruct(msg);
    PEP_rating color = PEP_rating_undefined;

    @synchronized (self) {
        outgoing_message_rating(_session, _msg, &color);
    }

    free_message(_msg);
    
    return color;
}

- (PEP_rating)identityRating:(nonnull NSDictionary<NSString *, id> *)identity
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

- (void)mySelf:(NSMutableDictionary<NSString *, id> *)identity
{
    [identity removeObjectForKey:kPepUserID];

    pEp_identity *ident = PEP_identityDictToStruct(identity);

    @synchronized(self) {
        myself(_session, ident);
    }

    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)updateIdentity:(NSMutableDictionary<NSString *, id> *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);

    @synchronized(self) {
        update_identity(_session, ident);
    }

    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)trustPersonalKey:(NSMutableDictionary<NSString *, id> *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);
    
    @synchronized(self) {
        trust_personal_key(_session, ident);
    }
    
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)keyResetTrust:(NSMutableDictionary<NSString *, id> *)identity
{
    pEp_identity *ident = PEP_identityDictToStruct(identity);
    
    @synchronized(self) {
        key_reset_trust(_session, ident);
    }
    
    [identity setValuesForKeysWithDictionary:PEP_identityDictFromStruct(ident)];
    free_identity(ident);
}

- (void)keyMistrusted:(NSMutableDictionary<NSString *, id> *)identity
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

- (nullable NSString *)getTrustwordsIdentity1:(nonnull NSDictionary<NSString *, id> *)identity1
                                    identity2:(nonnull NSDictionary<NSString *, id> *)identity2
                                     language:(nullable NSString *)language
                                         full:(BOOL)full
{
    NSString *result = nil;
    char *trustwords = nil;
    size_t sizeWritten = 0;

    pEp_identity *ident1 = PEP_identityDictToStruct(identity1);
    pEp_identity *ident2 = PEP_identityDictToStruct(identity2);
    PEP_STATUS status =  get_trustwords(_session, ident1, ident2,
                                        [[language precomposedStringWithCanonicalMapping]
                                         UTF8String],
                                        &trustwords, &sizeWritten, full);
    if (status == PEP_STATUS_OK) {
        result = [NSString stringWithCString:trustwords
                                    encoding:NSUTF8StringEncoding];
    }
    if (trustwords) {
        free(trustwords);
    }
    return result;
}

@end
