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

NSArray * _Nonnull PEP_arrayFromStringPairlist(stringpair_list_t * _Nonnull sl);
NSArray * _Nonnull PEP_arrayFromBloblist(bloblist_t * _Nonnull bl);
