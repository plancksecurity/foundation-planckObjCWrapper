//
//  PEPMessageUtil.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 09.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "message_api.h"

@class PEPIdentity;
@class PEPMessage;

pEp_identity * _Nullable PEP_identityToStruct(PEPIdentity * _Nullable dict);
NSDictionary * _Nonnull PEP_identityDictFromStruct(pEp_identity * _Nullable ident);

PEPMessage * _Nullable pEpMessageFromStruct(message * _Nullable msg);

message * _Nullable PEP_messageToStruct(PEPMessage * _Nullable message);
message * _Nullable PEP_messageDictToStruct(NSDictionary * _Nullable dict);
NSDictionary * _Nonnull PEP_messageDictFromStruct(message * _Nullable msg);

NSArray * _Nonnull PEP_arrayFromStringPairlist(stringpair_list_t * _Nonnull sl);
NSArray * _Nonnull PEP_arrayFromBloblist(bloblist_t * _Nonnull bl);
