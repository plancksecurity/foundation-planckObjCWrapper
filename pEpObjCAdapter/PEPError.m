//
//  PEPError.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 09.02.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPError.h"

const NSString * const kpEpFunctionName = @"kpEpFunctionName";

@implementation PEPError

/**
 Inititializes a new PEPError with the given pEp status code and
 optional (pEp) function name that caused the error.
 */
- (instancetype)initWithStatusCode:(NSInteger)statusCode
                      functionName:(NSString * _Nullable)functionName
{
    NSDictionary *userInfo = nil;
    if (functionName) {
        userInfo = @{kpEpFunctionName: functionName};
    }
    return [self initWithDomain:@"PEPError" code:statusCode userInfo:userInfo];
}

+ (instancetype)errorWithStatusCode:(NSInteger)statusCode
                       functionName:(NSString * _Nullable)functionName
{
    return [[PEPError alloc] initWithStatusCode:statusCode functionName:functionName];
}

@end
