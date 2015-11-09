//
//  MCOAddress+PEPIdentity.m
//  pEpiOSAdapter
//
//  Created by Edouard Tisserant on 09/11/15.
//  Copyright © 2015 p≡p. All rights reserved.
//

#import "MCOAddress+PEPIdentity.h"
#import "MCOAbstractMessage+PEPMessage.h"

@implementation MCOAddress (PEPIdentity)

NSString * _userId;

- (NSString*)userId
{
    return _userId;
}

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
}

- (id)initWithStruct:(pEp_identity *)ident
{
    if(self = [self init])
        [self PEP_fromStruct:ident];
    return self;
}

- (id)initWithDict:(NSMutableDictionary *)dict
{
    if(self = [self init]){
        pEp_identity * ident = PEP_identityToStruct(dict);
        [self PEP_fromStruct:ident];
        free_identity(ident);
    }
    return self;
}

- (pEp_identity *)PEP_toStruct;
{
    pEp_identity *ident = new_identity([[self.mailbox precomposedStringWithCanonicalMapping] UTF8String], NULL, [[self.userId precomposedStringWithCanonicalMapping] UTF8String], [[self.displayName precomposedStringWithCanonicalMapping] UTF8String]);
    return ident;
}

- (void)PEP_fromStruct:(pEp_identity *)ident;
{
    self.mailbox = [NSString stringWithUTF8String:ident->address];
    self.displayName = [NSString stringWithUTF8String:ident->username];
    self.userId = [NSString stringWithUTF8String:ident->user_id];
}



@end
