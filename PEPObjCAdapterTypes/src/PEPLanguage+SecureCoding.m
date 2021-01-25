//
//  PEPLanguage+SecureCoding.m
//  PEPObjCAdapter_iOS
//
//  Created by David Alarcon on 25/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPLanguage+SecureCoding.h"

@implementation PEPLanguage (SecureCoding)

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.code       forKey:@"code"];
    [coder encodeObject:self.name       forKey:@"name"];
    [coder encodeObject:self.sentence   forKey:@"sentence"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder {
    if (self = [self init]) {
        self.code =     [decoder decodeObjectOfClass:[NSString class] forKey:@"code"];
        self.name =     [decoder decodeObjectOfClass:[NSString class] forKey:@"sentence"];
        self.sentence = [decoder decodeObjectOfClass:[NSString class] forKey:@"userName"];
    }

    return self;
}

+ (BOOL)supportsSecureCoding {
    return  YES;
}

@end
