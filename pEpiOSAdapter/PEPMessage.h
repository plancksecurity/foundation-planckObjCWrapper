//
//  MCOAbstractMessage+PEPMessage.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 09.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "message_api.h"

NSArray *PEP_arrayFromStringlist(stringlist_t *sl);
stringlist_t *PEP_arrayToStringlist(NSArray *array);

pEp_identity *PEP_identityToStruct(NSDictionary *dict);
NSMutableDictionary *PEP_identityFromStruct(pEp_identity *ident);

message *PEP_messageToStruct(NSMutableDictionary *dict);
NSMutableDictionary *PEP_messageFromStruct(message *msg);
