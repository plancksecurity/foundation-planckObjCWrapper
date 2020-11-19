//
//  PEPLanguage.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 03.05.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <pEpObjCAdapterTypesHeaders/pEpObjCAdapterTypesHeaders.h>

@implementation PEPLanguage

- (instancetype _Nonnull)initWithCode:(NSString * _Nonnull)code
                                 name:(NSString * _Nonnull)name
                                 sentence:(NSString * _Nonnull)sentence
{
    if (self = [[PEPLanguage alloc] init]) {
        _code = code;
        _name = name;
        _sentence = sentence;
    }
    return self;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p> %@", [self class], self, self.description];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", self.code, self.name];
}

@end
