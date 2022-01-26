//
//  PEPAttachment+Convert.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 25/1/22.
//

#import <Foundation/Foundation.h>
#import "PEPAttachment.h"
#import <transport.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPAttachment (Convert)

+ (NSArray<PEPAttachment*> *)arrayFromBloblist:(const bloblist_t * _Nonnull)blobList;

+ (bloblist_t * _Nullable)arrayToBloblist:(NSArray<PEPAttachment*> *)array;

@end

NS_ASSUME_NONNULL_END
