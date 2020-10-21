//
//  NSArray+Engine.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSArray+Engine.h"

#import "PEPIdentity.h"
#import "PEPIdentity+Engine.h"
#import "PEPMessageUtil.h"

@implementation NSArray (Engine)

+ (NSArray * _Nonnull)arrayFromStringlist:(stringlist_t * _Nonnull)stringList
{
    NSMutableArray *array = [NSMutableArray array];

    for (stringlist_t *_sl = stringList; _sl && _sl->value; _sl = _sl->next) {
        [array addObject:[NSString stringWithUTF8String:_sl->value]];
    }

    return array;
}

+ (NSArray<PEPIdentity *> *)arrayFromIdentityList:(identity_list *)identityList
{
    NSMutableArray *array = [NSMutableArray array];

    for (identity_list *_il = identityList; _il && _il->ident; _il = _il->next) {
        [array addObject:[PEPIdentity fromStruct:_il->ident]];
    }

    return array;
}

- (stringlist_t * _Nullable)toStringList
{
    stringlist_t *sl = new_stringlist(NULL);
    if (!sl)
        return NULL;

    stringlist_t *_sl = sl;
    for (NSString *str in self) {
        _sl = stringlist_add(_sl, [[str precomposedStringWithCanonicalMapping] UTF8String]);
    }

    return sl;
}

- (identity_list * _Nullable)toIdentityList
{
    identity_list *il = new_identity_list(NULL);
    if (!il)
        return NULL;

    identity_list *_il = il;
    for (NSMutableDictionary *address in self) {
        _il = identity_list_add(_il, PEP_identityDictToStruct(address));
    }

    return il;
}

@end
