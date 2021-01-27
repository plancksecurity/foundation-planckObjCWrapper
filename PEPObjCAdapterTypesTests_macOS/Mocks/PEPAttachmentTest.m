//
//  PEPAttachmentTest.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPAttachmentTest.h"

@implementation PEPAttachmentTest

- (instancetype)init {
    if (self = [super init]) {
        self.data = [@"attachment" dataUsingEncoding:NSUTF8StringEncoding];
        self.size = self.data.length;
        self.mimeType = @"text/plain";
        self.filename = @"attachment.txt";
        self.contentDisposition = PEPContentDispositionAttachment;
    }

    return  self;
}

@end
