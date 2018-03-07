//
//  NSError+PEP.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 20.02.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "NSError+PEP.h"

@implementation NSError (Extension)

+ (NSError *)errorWithPEPStatus:(PEP_STATUS)status
                       userInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict
{
    if (status != PEP_STATUS_OK && status != PEP_DECRYPTED) {
        return [NSError errorWithDomain:@"pEp" code:status userInfo:dict];
    }
    return nil;
}

+ (NSError *)errorWithPEPStatus:(PEP_STATUS)status
{
    return [self errorWithPEPStatus:status userInfo:nil];
}

+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromPEPStatus:(PEP_STATUS)status
{
    NSError *theError = [self errorWithPEPStatus:status];
    if (theError) {
        if (error) {
            *error = theError;
        }
        return YES;
    } else {
        if (error) {
            *error = nil;
        }
        return NO;
    }
}

@end
