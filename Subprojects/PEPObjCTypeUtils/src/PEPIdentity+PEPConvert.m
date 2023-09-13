//
//  PEPIdentity+PEPConvert.m
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 25/1/22.
//

#import "PEPIdentity.h"
#import "PEPIdentity+PEPConvert.h"

@implementation PEPIdentity (PEPConvert)

+ (PEPIdentity * _Nullable)fromStruct:(const pEp_identity * _Nonnull)identityStruct
{
    PEPIdentity *identity = nil;

    if (identityStruct->address && identityStruct->address[0]) {
        identity = [[PEPIdentity alloc]
                    initWithAddress:[NSString stringWithUTF8String:identityStruct->address]];
    }
    [self overwritePEPIdentityObject:identity withValuesFromStruct:identityStruct];
    return identity;
}

+ (void)overwritePEPIdentityObject:(PEPIdentity *)pEpIdentity
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

    pEpIdentity.majorVersion = identityStruct->major_ver;
    pEpIdentity.minorVersion = identityStruct->minor_ver;

    pEpIdentity.encryptionFormat = identityStruct->enc_format;
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

    ident->major_ver = self.majorVersion;
    ident->minor_ver = self.minorVersion;

    ident->enc_format = self.encryptionFormat;

    return ident;
}

@end
