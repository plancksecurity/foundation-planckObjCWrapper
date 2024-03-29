//
//  PEPLanguage.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 03.05.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPLanguage.h"

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

// MARK: - NSSecureCoding

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder {
    if (self = [self init]) {
        self.code = [decoder decodeObjectOfClass:[NSString class] forKey:@"code"];
        self.name = [decoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        self.sentence = [decoder decodeObjectOfClass:[NSString class] forKey:@"sentence"];
    }

    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.code forKey:@"code"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.sentence forKey:@"sentence"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
