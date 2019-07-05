//
//  PEPAttachment.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 16.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPEngineTypes.h"

@interface PEPAttachment : NSObject

/**
 The blob (binary data) of this attachment, terminated by one \0.
 */
@property (readonly, nonnull) NSData *dataWithZeroTerminator;

/**
 The blob (binary data) of this attachment, _without_ \0 terminator.
 */
@property (readonly, nonnull) NSData *dataWithoutZeroTerminator;

/**
 The size (length in bytes) of the binary blob _without_ the trailing \0,
 in other words, the size of the raw data.
 */
@property (nonatomic) NSInteger size;

@property (nonatomic, nullable) NSString *mimeType;
@property (nonatomic, nullable) NSString *filename;
@property (nonatomic) PEPContentDisposition contentDisposition;

- (_Nonnull instancetype)initWithData:(NSData * _Nonnull)data;

@end
