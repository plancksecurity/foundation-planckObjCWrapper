//
//  PEPSession.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 08.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "PEPSession.h"
#import "pEpOSXAdapter.h"
#import "MCOAbstractMessage+PEPMessage.h"

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
    
    [pEpOSXAdapter registerExamineFunction:_session];
    return self;
}

- (void)dealloc
{
    release(_session);
}

- (PEP_color)decryptMessage:(MCOAbstractMessage *)src dest:(MCOAbstractMessage **)dst keys:(NSArray **)keys
{
    message * _src = [src PEP_toStruct];
    message * _dst = NULL;
    stringlist_t * _keys = NULL;
    PEP_color color = PEP_rating_undefined;

    @synchronized (self) {
        decrypt_message(_session, _src, &_dst, &_keys, &color);
    }

    MCOAbstractMessage * dst_ = [MCOMessageBuilder new];

    if (_dst) {
        [dst_ PEP_fromStruct:_dst];
    }
    else {
        [dst_ PEP_fromStruct:_src];
    }

    NSArray * keys_ = NULL;
    if (_keys)
        keys_ = PEP_arrayFromStringlist(_keys);

    free_message(_src);
    free_message(_dst);
    free_stringlist(_keys);

    *dst = dst_;
    *keys = keys_;
    return color;
}

- (void)encryptMessage:(MCOAbstractMessage *)src extra:(NSArray *)keys dest:(MCOAbstractMessage **)dst
{
    message * _src = [src PEP_toStruct];
    message * _dst = NULL;
    stringlist_t * _keys = PEP_arrayToStringlist(keys);

    @synchronized (self) {
        encrypt_message(_session, _src, _keys, &_dst, PEP_enc_PGP_MIME);
    }

    MCOAbstractMessage * dst_ = [MCOMessageBuilder new];

    if (_dst) {
        [dst_ PEP_fromStruct:_dst];
    }
    else {
        [dst_ PEP_fromStruct:_src];
    }

    free_message(_src);
    free_message(_dst);
    free_stringlist(_keys);
}

- (PEP_color)outgoingMessageColor:(MCOAbstractMessage *)msg
{
    message *_msg = [msg PEP_toStruct];
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
        update_identity(_session, ident);
    }

    PEP_identityFromStruct(identity, ident);
    free_identity(ident);
}

- (void)updateIdentity:(NSMutableDictionary *)identity
{
    pEp_identity *ident = PEP_identityToStruct(identity);

    @synchronized(self) {
        update_identity(_session, ident);
    }

    PEP_identityFromStruct(identity, ident);
    free_identity(ident);
}

- (void)keyCompromized:(NSString *)fpr
{
    const char *str = [[fpr precomposedStringWithCanonicalMapping] UTF8String];

    @synchronized(self) {
        key_compromized(_session, str);
    }
}

@end
