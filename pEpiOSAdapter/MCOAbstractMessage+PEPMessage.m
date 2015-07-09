//
//  MCOAbstractMessage+PEPMessage.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 09.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "MCOAbstractMessage+PEPMessage.h"

NSArray *PEP_arrayFromStringlist(stringlist_t *sl)
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (stringlist_t *_sl = sl; _sl && _sl->value; _sl = _sl->next) {
        [array addObject:[NSString stringWithUTF8String:_sl->value]];
    }
    
    return array;
}

stringlist_t *PEP_arrayToStringlist(NSArray *array)
{
    stringlist_t *sl = new_stringlist(NULL);
    if (!sl)
        return NULL;
    
    stringlist_t *_sl = sl;
    for (NSString *str in array) {
        _sl = stringlist_add(_sl, [[str precomposedStringWithCanonicalMapping] UTF8String]);
    }
    
    return sl;
}

void PEP_identityFromStruct(NSMutableDictionary *dict, pEp_identity *ident)
{
    if (ident) {
        if (ident->address && ident->address[0])
            [dict setObject:[NSString stringWithUTF8String:ident->address] forKey:@"address"];
        
        if (ident->fpr && ident->fpr[0])
            [dict setObject:[NSString stringWithUTF8String:ident->fpr] forKey:@"fpr"];
        
        if (ident->user_id && ident->user_id[0])
            [dict setObject:[NSString stringWithUTF8String:ident->user_id] forKey:@"user_id"];

        if (ident->username && ident->username[0])
            [dict setObject:[NSString stringWithUTF8String:ident->username] forKey:@"username"];

        if (ident->lang[0])
            [dict setObject:[NSString stringWithUTF8String:ident->lang] forKey:@"lang"];
        
        [dict setObject:[NSNumber numberWithInt: ident->comm_type] forKey:@"comm_type"];
        
        if (ident->me)
            [dict setObject:@YES forKey:@"me"];
        else
            [dict setObject:@NO forKey:@"me"];
    }
}

pEp_identity *PEP_identityToStruct(NSDictionary *dict)
{
    pEp_identity *ident = new_identity(NULL, NULL, NULL, NULL);
    
    if (dict && ident) {
        if ([dict objectForKey:@"address"])
            ident->address = strdup(
                                    [[[dict objectForKey:@"address"] precomposedStringWithCanonicalMapping] UTF8String]
                                    );
        
        if ([dict objectForKey:@"fpr"])
            ident->fpr = strdup(
                                [[[dict objectForKey:@"fpr"] precomposedStringWithCanonicalMapping] UTF8String]
                                );
        
        if ([dict objectForKey:@"user_id"])
            ident->user_id = strdup(
                                    [[[dict objectForKey:@"user_id"] precomposedStringWithCanonicalMapping] UTF8String]
                                    );
        
        if ([dict objectForKey:@"username"])
            ident->username = strdup(
                                     [[[dict objectForKey:@"username"] precomposedStringWithCanonicalMapping] UTF8String]
                                     );
        
        if ([dict objectForKey:@"lang"])
            strncpy(ident->fpr, [[[dict objectForKey:@"lang"] precomposedStringWithCanonicalMapping] UTF8String], 2);
        
        if ([[dict objectForKey:@"me"] isEqual: @YES])
            ident->me = true;
        
        if ([dict objectForKey:@"comm_type"])
            ident->comm_type = [[dict objectForKey:@"comm_type"] intValue];
    }
    
    return ident;
}

NSArray *PEP_arrayFromIdentityList(identity_list *il)
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (identity_list *_il = il; _il && _il->ident; _il = _il->next) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        PEP_identityFromStruct(dict, il->ident);
        [array addObject:dict];
    }
    
    return array;
}

identity_list *PEP_arrayToIdentityList(NSArray *array)
{
    identity_list *il = new_identity_list(NULL);
    if (!il)
        return NULL;
    
    identity_list *_il = il;
    for (NSDictionary *dict in array) {
        _il = identity_list_add(_il, PEP_identityToStruct(dict));
    }
    
    return il;
}

@class MCOAbstractMessage;

@implementation MCOAbstractMessage (PEPMessage)

- (void)PEP_fromStruct:(message *)msg
{
    
}

- (message *)PEP_toStruct
{
    return NULL;
}

@end
