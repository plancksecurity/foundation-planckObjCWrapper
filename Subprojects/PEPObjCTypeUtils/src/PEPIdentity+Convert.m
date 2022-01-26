//
//  PEPIdentity+Convert.m
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 25/1/22.
//

#import "PEPIdentity.h"
#import "PEPIdentity+Convert.h"

@implementation PEPIdentity (Convert)

+ (PEPIdentity * _Nullable)pEpIdentityfromStruct:(const pEp_identity * _Nonnull)identityStruct
{
    PEPIdentity *identity = nil;

    if (identityStruct->address && identityStruct->address[0]) {
        identity = [[PEPIdentity alloc]
                    initWithAddress:[NSString stringWithUTF8String:identityStruct->address]];
    }
    [self overWritePEPIdentityObject:identity withValuesFromStruct:identityStruct];
    return identity;
}

+ (pEp_identity *)structFromPEPIdentity:(PEPIdentity *)pEpIdentity
{
    pEp_identity *ident = new_identity([[pEpIdentity.address
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[pEpIdentity.fingerPrint
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[pEpIdentity.userID
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[pEpIdentity.userName
                                         precomposedStringWithCanonicalMapping] UTF8String]);
    ident->me = pEpIdentity.isOwn;
    ident->flags = pEpIdentity.flags;

    if (pEpIdentity.language) {
        strncpy(ident->lang, [[pEpIdentity.language
                               precomposedStringWithCanonicalMapping] UTF8String], 2);
    }

    ident->comm_type = (PEP_comm_type) pEpIdentity.commType;

    return ident;
}

+ (void)overWritePEPIdentityObject:(PEPIdentity *)pEpIdentity
              withValuesFromStruct:(const pEp_identity * _Nonnull)identityStruct
{
    if (identityStruct->address && identityStruct->address[0]) {
        pEpIdentity.address = [NSString stringWithUTF8String:identityStruct->address];
    }

    if (identityStruct->fpr && identityStruct->fpr[0]) {
        pEpIdentity.fingerPrint = [NSString stringWithUTF8String:identityStruct->fpr];
    }

    if (identityStruct->user_id && identityStruct->user_id[0]) {
        pEpIdentity.userID = [NSString stringWithUTF8String:identityStruct->user_id];
    }

    if (identityStruct->username && identityStruct->username[0]) {
        pEpIdentity.userName = [NSString stringWithUTF8String:identityStruct->username];
    }

    if (identityStruct->lang[0]) {
        pEpIdentity.language = [NSString stringWithUTF8String:identityStruct->lang];
    }

    pEpIdentity.commType = (PEPCommType) identityStruct->comm_type;

    pEpIdentity.isOwn = identityStruct->me;
    pEpIdentity.flags = identityStruct->flags;
}

+ (NSArray<PEPIdentity*> *)arrayFromIdentityList:(identity_list *)identityList {
    NSMutableArray *array = [NSMutableArray array];

    for (identity_list *_il = identityList; _il && _il->ident; _il = _il->next) {
        [array addObject:[self pEpIdentityfromStruct:_il->ident]];
    }

    return array;
}

+ (identity_list * _Nullable)arrayToIdentityList:(NSArray<PEPIdentity*> *)array {
    if (array.count == 0) {
        return NULL;
    }

    identity_list *il = new_identity_list(NULL);
    if (!il)
        return NULL;

    identity_list *_il = il;
    for (PEPIdentity *identity in array) {
        _il = identity_list_add(_il, [self structFromPEPIdentity:identity]);
    }

    return il;
}

@end
