//
//  NSArray+PEPConvert2.m
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 28/1/22.
//

#import <Foundation/Foundation.h>
#import "identity_list.h"
#import <pEp_string.h>
#import <status_to_string.h>
#import "PEPIdentity+Convert.h"

@implementation NSArray (PEPIdentityList)


+ (NSArray<PEPIdentity*> *)fromIdentityList:(identity_list *)identityList {
    NSMutableArray *array = [NSMutableArray array];

    for (identity_list *_il = identityList; _il && _il->ident; _il = _il->next) {
        [array addObject:[PEPIdentity fromStruct:_il->ident]];
    }
    return array;
}

- (identity_list * _Nullable)toIdentityList {
    if (self.count == 0) {
        return NULL;
    }

    identity_list *il = new_identity_list(NULL);
    if (!il)
        return NULL;

    identity_list *_il = il;
    for (PEPIdentity *identity in self) {
        _il = identity_list_add(_il, [identity toStruct]);
    }

    return il;
}

@end
