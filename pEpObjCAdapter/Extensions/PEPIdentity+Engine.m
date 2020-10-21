//
//  PEPIdentity+Engine.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPIdentity+Engine.h"

@implementation PEPIdentity (Engine)

+ (PEPIdentity * _Nullable)fromStruct:(pEp_identity * _Nonnull)identityStruct
{
    PEPIdentity *identity = nil;

    if (identityStruct->address && identityStruct->address[0]) {
        identity = [[PEPIdentity alloc]
                    initWithAddress:[NSString stringWithUTF8String:identityStruct->address]];
    }

    if (identityStruct->fpr && identityStruct->fpr[0]) {
        identity.fingerPrint = [NSString stringWithUTF8String:identityStruct->fpr];
    }

    if (identityStruct->user_id && identityStruct->user_id[0]) {
        identity.userID = [NSString stringWithUTF8String:identityStruct->user_id];
    }

    if (identityStruct->username && identityStruct->username[0]) {
        identity.userName = [NSString stringWithUTF8String:identityStruct->username];
    }

    if (identityStruct->lang[0]) {
        identity.language = [NSString stringWithUTF8String:identityStruct->lang];
    }

    identity.commType = (PEPCommType) identityStruct->comm_type;

    identity.isOwn = identityStruct->me;
    identity.flags = identityStruct->flags;

    return identity;
}

- (pEp_identity *)toStruct
{
    pEp_identity *ident = new_identity([[self.address
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[self.fingerPrint
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[self.userID
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[self.userName
                                         precomposedStringWithCanonicalMapping] UTF8String]);

    ident->me = self.isOwn;
    ident->flags = self.flags;

    if (self.language) {
        strncpy(ident->lang, [[self.language
                               precomposedStringWithCanonicalMapping] UTF8String], 2);
    }

    ident->comm_type = (PEP_comm_type) self.commType;

    return ident;
}

@end
