//
//  PEPMediaKeyPair.m
//  PEPObjCTypes
//
//  Created by Dirk Zimmermann on 06.09.22.
//

#import "PEPMediaKeyPair.h"

@implementation PEPMediaKeyPair

- (instancetype)initWithPattern:(NSString *)pattern fingerprint:(NSString *)fingerprint
{
    self = [super init];
    if (self) {
        _pattern = pattern;
        _fingerprint = fingerprint;
    }
    return self;
}

@end
