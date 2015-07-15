//
//  PEPSession.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 08.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "PEPSession.h"
#import "MCOAbstractMessage+PEPMessage.h"

@implementation PEPSession

@class MCOAbstractMessage;

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

- (PEP_color)decryptMessage:(MCOAbstractMessage *)src dest:(MCOAbstractMessage *)dst keys:(NSArray **)keys
{
    
    return PEP_rating_undefined;
}

- (void)encryptMessage:(MCOAbstractMessage *)src extra:(NSArray *)keys dest:(MCOAbstractMessage *)dst
{
    
}

- (PEP_color)outgoingMessageColor:(MCOAbstractMessage *)msg
{
    
    return PEP_rating_undefined;
}

- (NSArray *)trustwords:(NSString *)fpr forLanguage:(NSString *)languageID shortened:(BOOL)shortened
{

    return nil;
}

- (void)mySelf:(NSMutableDictionary *)identity
{
    @synchronized(self) {
        pEp_identity *ident = PEP_identityToStruct(identity);
        update_identity(_session, ident);
        PEP_identityFromStruct(identity, ident);
        free_identity(ident);
    }
}

- (void)updateIdentity:(NSMutableDictionary *)identity
{
    @synchronized(self) {
        pEp_identity *ident = PEP_identityToStruct(identity);
        update_identity(_session, ident);
        PEP_identityFromStruct(identity, ident);
        free_identity(ident);
    }
}

- (void)keyCompromized:(NSString *)fpr
{
    @synchronized(self) {
        const char *str = [[fpr precomposedStringWithCanonicalMapping] UTF8String];
        key_compromized(_session, str);
    }
}

@end
