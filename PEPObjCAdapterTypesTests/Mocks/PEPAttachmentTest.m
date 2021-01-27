//
//  PEPAttachmentTest.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPAttachmentTest.h"

#import "NSObject+Extension.h"

@implementation PEPAttachmentTest

- (instancetype)init {
    if (self = [super init]) {
        self.data = [@"attachment" dataUsingEncoding:NSUTF8StringEncoding];
        self.size = self.data.length;
        self.mimeType = @"text/plain";
        self.filename = @"attachment.txt";
        self.contentDisposition = PEPContentDispositionAttachment;
        s_keys = @[@"data", @"size", @"mimeType", @"filename", @"contentDisposition"];
    }

    return  self;
}

// MARK: - Equality

/**
 The keys that should be used to decide `isEqual` and compute the `hash`.
 */
static NSArray *s_keys;

- (BOOL)isEqualToPEPAttachment:(PEPAttachment * _Nonnull)attachment
{
    return [self isEqualToObject:attachment basedOnKeys:s_keys];
}

- (NSUInteger)hash
{
    return [self hashBasedOnKeys:s_keys];
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }

    return [self isEqualToPEPAttachment:object];
}

@end
