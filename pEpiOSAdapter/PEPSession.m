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

@implementation PEPSession

PEP_SESSION _session;

+ (PEPSession *)session
{
    PEPSession *_session = [[PEPSession alloc] init];
    return _session;
}

- (id)init
{
    PEP_STATUS status = init(&_session);
    if (status != PEP_STATUS_OK) {
        NSException* myException = [NSException
                                    exceptionWithName:@"PEPInitError"
                                    reason:@"Cannot initialize pEp engine"
                                    userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger: status] forKey: @"status"]];
        
        @throw myException;
    }
    
    [PEPiOSAdapter registerExamineFunction:_session];
    return self;
}

- (void)dealloc
{
    release(_session);
}

- (PEP_color)decryptMessage:(NSMutableDictionary *)src dest:(NSMutableDictionary **)dst keys:(NSArray **)keys
{
    message * _src = PEP_messageToStruct(src);
    message * _dst = NULL;
    stringlist_t * _keys = NULL;
    PEP_color color = PEP_rating_undefined;

    @synchronized (self) {
        decrypt_message(_session, _src, &_dst, &_keys, &color);
    }

    NSMutableDictionary * dst_;

    if (_dst) {
        dst_ = PEP_messageFromStruct(_dst);
    }
    else {
        dst_ = PEP_messageFromStruct(_src);
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

- (PEP_STATUS)encryptMessage:(NSMutableDictionary *)src extra:(NSArray *)keys dest:(NSMutableDictionary **)dst
{
    PEP_STATUS status;
    message * _src = PEP_messageToStruct(src);
    message * _dst = NULL;
    stringlist_t * _keys = PEP_arrayToStringlist(keys);

    @synchronized (self) {
        status = encrypt_message(_session, _src, _keys, &_dst, PEP_enc_PGP_MIME);
    }

    NSMutableDictionary * dst_;

    if (_dst) {
        dst_ = PEP_messageFromStruct(_dst);
    }
    else {
        dst_ = PEP_messageFromStruct(_src);
    }
    *dst = dst_;

    free_message(_src);
    free_message(_dst);
    free_stringlist(_keys);
    
    return status;
}

- (PEP_color)outgoingMessageColor:(NSMutableDictionary *)msg
{
    message * _msg = PEP_messageToStruct(msg);
    PEP_color color = PEP_rating_undefined;

    @synchronized (self) {
        outgoing_message_color(_session, _msg, &color);
    }

    free_message(_msg);
    
    return color;
}

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
    pEp_identity *ident = PEP_identityToStruct(identity);

    @synchronized(self) {
        myself(_session, ident);
    }

    [identity setValuesForKeysWithDictionary:PEP_identityFromStruct(ident)];
    free_identity(ident);
}

- (void)updateIdentity:(NSMutableDictionary *)identity
{
    pEp_identity *ident = PEP_identityToStruct(identity);

    @synchronized(self) {
        update_identity(_session, ident);
    }

    [identity setValuesForKeysWithDictionary:PEP_identityFromStruct(ident)];
    free_identity(ident);
}

- (void)trustPersonalKey:(NSMutableDictionary *)identity
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    
    @synchronized(self) {
        trust_personal_key(_session, ident);
    }
    
    [identity setValuesForKeysWithDictionary:PEP_identityFromStruct(ident)];
    free_identity(ident);
}

- (void)keyCompromized:(NSMutableDictionary *)identity
{
    pEp_identity *ident = PEP_identityToStruct(identity);
    
    @synchronized(self) {
        key_compromized(_session, ident);
    }
    
    [identity setValuesForKeysWithDictionary:PEP_identityFromStruct(ident)];
    free_identity(ident);
}

- (void)importKey:(NSString *)keydata
{
    @synchronized(self) {
        import_key(_session, [keydata UTF8String], [keydata length]);
    }

}


@end
