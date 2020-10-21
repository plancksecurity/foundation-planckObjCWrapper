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
