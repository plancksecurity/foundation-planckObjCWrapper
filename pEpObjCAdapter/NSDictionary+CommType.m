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

@implementation NSDictionary (CommType)

- (PEPCommType)commType
{
    NSNumber *ctNum = self[kPepCommType];
    if (!ctNum) {
        return PEPCommTypeUnknown;
    }
    return ctNum.intValue;
}

@end
