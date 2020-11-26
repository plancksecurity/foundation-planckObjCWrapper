//
//  PEPAttachment.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 16.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_CLOSED_ENUM(int, PEPContentDisposition) {
    PEPContentDispositionAttachment = 0, // PEP_CONTENT_DISP_ATTACHMENT
    PEPContentDispositionInline = 1, // PEP_CONTENT_DISP_INLINE
    PEPContentDispositionOther = -1 // PEP_CONTENT_DISP_OTHER
};

@interface PEPAttachment : NSObject

@property (nonatomic, nonnull) NSData *data;
@property (nonatomic) NSInteger size;
@property (nonatomic, nullable) NSString *mimeType;
@property (nonatomic, nullable) NSString *filename;
@property (nonatomic) PEPContentDisposition contentDisposition;

- (_Nonnull instancetype)initWithData:(NSData * _Nonnull)data;

@end
