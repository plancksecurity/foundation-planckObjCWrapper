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

+ (instancetype _Nullable)fromStruct:(pEp_identity * _Nonnull)identityStruct
{
    PEPIdentity *identity = nil;

    if (identityStruct->address && identityStruct->address[0]) {
        identity = [[PEPIdentity alloc]
                    initWithAddress:[NSString stringWithUTF8String:identityStruct->address]];
    }

    [identity overWriteFromStruct:identityStruct];

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

- (void)overWriteFromStruct:(pEp_identity * _Nonnull)identityStruct
{
    if (identityStruct->address && identityStruct->address[0]) {
        self.address = [NSString stringWithUTF8String:identityStruct->address];
    }

    if (identityStruct->fpr && identityStruct->fpr[0]) {
        self.fingerPrint = [NSString stringWithUTF8String:identityStruct->fpr];
    }

    if (identityStruct->user_id && identityStruct->user_id[0]) {
        self.userID = [NSString stringWithUTF8String:identityStruct->user_id];
    }

    if (identityStruct->username && identityStruct->username[0]) {
        self.userName = [NSString stringWithUTF8String:identityStruct->username];
    }

    if (identityStruct->lang[0]) {
        self.language = [NSString stringWithUTF8String:identityStruct->lang];
    }

    self.commType = (PEPCommType) identityStruct->comm_type;

    self.isOwn = identityStruct->me;
    self.flags = identityStruct->flags;
}

@end
