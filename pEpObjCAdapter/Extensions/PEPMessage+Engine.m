//
//  PEPMessage+Engine.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPMessage+Engine.h"

#import "PEPMessageUtil.h"

@implementation PEPMessage (Engine)

+ (PEPMessage * _Nullable)fromStruct:(message * _Nullable)msg
{
    if (!msg) {
        return nil;
    }
    NSDictionary *dict = PEP_messageDictFromStruct(msg);
    PEPMessage *theMessage = [PEPMessage new];
    [theMessage setValuesForKeysWithDictionary:dict];
    return theMessage;
}

- (message * _Nullable)toStruct
{
    return PEP_messageDictToStruct((NSDictionary *) self);
}

- (void)removeEmptyRecipients
{
    if (self.to.count == 0) {
        self.to = nil;
    }

    if (self.cc.count == 0) {
        self.cc = nil;
    }

    if (self.bcc.count == 0) {
        self.bcc = nil;
    }
}

@end
