//
//  NSArray+PEPConvert.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 28/1/22.
//

#import <Foundation/Foundation.h>

#import "bloblist.h"
#import "stringpair.h"
#import "stringlist.h"

#import "PEPIdentity+PEPConvert.h"
#import "PEPMessage+PEPConvert.h"

@class PEPMessage;
@class PEPIdentity;
@class PEPAttachment;

NS_ASSUME_NONNULL_BEGIN

// NSArray<PEPAttachment> <-> bloblist_t

@interface NSArray (PEPConvert)

+ (NSArray<PEPAttachment*> *)fromBloblist:(const bloblist_t * _Nonnull)blobList;

- (bloblist_t * _Nullable)toBloblist;


+ (NSArray<NSString*> *)fromStringlist:(const stringlist_t * _Nonnull)stringList;

- (stringlist_t * _Nullable)toStringList;

// MARK: - NSArray <-> stringpair_list_t

+ (NSArray<NSArray<NSString*>*> *)fromStringPairlist:(const stringpair_list_t * _Nonnull)stringPairList;

- (stringpair_list_t * _Nullable)toStringPairList;


@end

NS_ASSUME_NONNULL_END
