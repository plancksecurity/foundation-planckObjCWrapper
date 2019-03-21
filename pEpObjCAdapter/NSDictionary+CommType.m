//
//  NSDictionary+CommType.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.09.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDictionary+CommType.h"

#import "PEPConstants.h"

#import "PEPMessageUtil.h"

@implementation NSDictionary (CommType)

- (PEP_comm_type)commType
{
    NSNumber *ctNum = self[kPepCommType];
    if (!ctNum) {
        return PEP_ct_unknown;
    }
    return ctNum.intValue;
}

@end
