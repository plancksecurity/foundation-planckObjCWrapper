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

@property (nonatomic) NSData *data;
@property (nonatomic) NSInteger size;
@property (nonatomic, nullable) NSString *mimeType;
@property (nonatomic, nullable) NSString *filename;
@property (nonatomic) PEPContentDisposition contentDisposition;

- (_Nonnull instancetype)initWithData:(NSData *)data;

@end
