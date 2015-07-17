//
//  MCOAbstractMessage+PEPMessage.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 09.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>
#include "message_api.h"

pEp_identity *PEP_identityToStruct(NSDictionary *dict);
void PEP_identityFromStruct(NSMutableDictionary *dict, pEp_identity *ident);

@interface MCOAbstractMessage (PEPMessage)

@property BOOL outgoing;

- (void)PEP_fromStruct:(message *)msg;
- (message *)PEP_toStruct;

@end
