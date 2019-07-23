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

NSArray * _Nonnull PEP_arrayFromStringlist(stringlist_t * _Nonnull sl);
stringlist_t * _Nullable PEP_arrayToStringlist(NSArray * _Nullable array);

pEp_identity * _Nonnull PEP_identityToStruct(PEPIdentity * _Nonnull identity);

/**
 If the ident does not contain an address, no PEPIdentity can be constructed.
 */
PEPIdentity * _Nullable PEP_identityFromStruct(pEp_identity * _Nonnull ident);

NSArray<PEPIdentity *> * _Nonnull PEPIdentityArrayFromIdentityList(identity_list * _Nonnull il);
identity_list * _Nullable PEP_identityArrayToList(NSArray<PEPIdentity *> * _Nullable array);

pEp_identity * _Nullable PEP_identityDictToStruct(NSDictionary * _Nullable dict);
NSDictionary * _Nonnull PEP_identityDictFromStruct(pEp_identity * _Nullable ident);

PEPMessage * _Nullable pEpMessageFromStruct(message * _Nullable msg);

message * _Nullable PEP_messageToStruct(PEPMessage * _Nullable message);
message * _Nullable PEP_messageDictToStruct(NSDictionary * _Nullable dict);
NSDictionary * _Nonnull PEP_messageDictFromStruct(message * _Nullable msg);

NSArray * _Nonnull PEP_arrayFromStringPairlist(stringpair_list_t * _Nonnull sl);
NSArray * _Nonnull PEP_arrayFromBloblist(bloblist_t * _Nonnull bl);
