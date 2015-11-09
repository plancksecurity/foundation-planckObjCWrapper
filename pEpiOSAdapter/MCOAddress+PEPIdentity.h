//
//  MCOAddress+PEPIdentity.h
//  pEpiOSAdapter
//
//  Created by Edouard Tisserant on 09/11/15.
//  Copyright © 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MCOAddress.h>
#include "message_api.h"

@interface MCOAddress (PEPIdentity)

@property NSString* userId;

- (id)initWithStruct:(pEp_identity *)ident;
- (id)initWithDict:(NSMutableDictionary *)dict;
- (void)PEP_fromStruct:(pEp_identity *)ident;
- (pEp_identity *)PEP_toStruct;

@end
