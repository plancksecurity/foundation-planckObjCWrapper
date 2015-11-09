//
//  MCOAbstractMessage+PEPMessage.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 09.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCOAddress+PEPIdentity.h"
#import <MailCore/MCOAbstract.h>
#include "message_api.h"

NSArray *PEP_arrayFromStringlist(stringlist_t *sl);
stringlist_t *PEP_arrayToStringlist(NSArray *array);
pEp_identity *PEP_identityToStruct(NSDictionary *dict);
void PEP_identityFromStruct(NSMutableDictionary *dict, pEp_identity *ident);

@interface MCOAbstractMessage (PEPMessage)

@property BOOL outgoing;

- (void)PEP_fromStruct:(message *)msg;
- (message *)PEP_toStruct;

@end
