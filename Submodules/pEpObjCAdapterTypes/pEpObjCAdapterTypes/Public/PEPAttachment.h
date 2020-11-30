//
//  PEPAttachment.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 16.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#ifndef PEPAttachment_h
#define PEPAttachment_h

#import <Foundation/Foundation.h>

#ifdef FRAMEWORK_BUILD
#import <PEPObjCAdapterTypesFramework/PEPContentDisposition.h>
#else
#import "PEPContentDisposition.h"
#endif

@interface PEPAttachment : NSObject

@property (nonatomic, nonnull) NSData *data;
@property (nonatomic) NSInteger size;
@property (nonatomic, nullable) NSString *mimeType;
@property (nonatomic, nullable) NSString *filename;
@property (nonatomic) PEPContentDisposition contentDisposition;

- (_Nonnull instancetype)initWithData:(NSData * _Nonnull)data;

@end

#endif
