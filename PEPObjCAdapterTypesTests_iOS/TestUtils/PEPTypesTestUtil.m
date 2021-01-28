//
//  PEPTypesTestUtil.m
//  PEPObjCAdapterTypesTests_iOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPTypesTestUtil.h"

#import "PEPIdentity.h"
#import "PEPAttachment.h"
#import "PEPLanguage.h"

@implementation PEPTypesTestUtil

+ (PEPIdentity *)pEpIdentityWithAllFieldsFilled {
    PEPIdentity *identity = [PEPIdentity new];

    identity.address = @"test@host.com";
    identity.userID = @"pEp_own_userId";
    identity.fingerPrint = @"184C1DE2D4AB98A2A8BB7F23B0EC5F483B62E19D";
    identity.language = @"cat";
    identity.commType = PEPCommTypePEP;
    identity.isOwn = YES;
    identity.flags = PEPIdentityFlagsNotForSync;

    return identity;
}

+ (PEPAttachment *)pEpAttachmentWithAllFieldsFilled {
    PEPAttachment *attachment = [PEPAttachment new];

    attachment.data = [@"attachment" dataUsingEncoding:NSUTF8StringEncoding];
    attachment.size = attachment.data.length;
    attachment.mimeType = @"text/plain";
    attachment.filename = @"attachment.txt";
    attachment.contentDisposition = PEPContentDispositionAttachment;

    return attachment;
}

+ (PEPLanguage *)pEpLanguageWithAllFieldsFilled {
    PEPLanguage *language = [PEPLanguage new];

    language.code = @"cat";
    language.name = @"Català";
    language.sentence = @"Bon profit";

    return language;
}

@end
