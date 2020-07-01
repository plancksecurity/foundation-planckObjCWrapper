//
//  NSString+NormalizePassphrase.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 01.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "NSString+NormalizePassphrase.h"

#import "PEPSessionProtocol.h"

/// The maximum number of code points allowed in a passphrase
static NSUInteger s_passphraseMaxNumberOfCodePoints = 250;

@implementation NSString (NormalizePassphrase)

- (NSString * _Nullable)normalizedPassphraseWithError:(NSError * _Nullable * _Nullable)error
{
    NSString *normalizedPassphrase = [self precomposedStringWithCanonicalMapping];

    if ([normalizedPassphrase length] > s_passphraseMaxNumberOfCodePoints) {
        if (error) {
            *error = [NSError errorWithDomain:PEPObjCAdapterEngineStatusErrorDomain
                                         code:PEPAdapterErrorPassphraseTooLong
                                     userInfo:nil];
            return nil;
        }
    }

    return normalizedPassphrase;
}

@end
