//
//  NSDictionary+Extension.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.09.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDictionary+Extension.h"

#import "PEPMessageUtil.h"

@implementation NSDictionary (Extension)

- (PEP_comm_type)commType
{
    NSNumber *ctNum = self[kPepCommType];
    if (!ctNum) {
        return PEP_ct_unknown;
    }
    return ctNum.intValue;
}

@end
