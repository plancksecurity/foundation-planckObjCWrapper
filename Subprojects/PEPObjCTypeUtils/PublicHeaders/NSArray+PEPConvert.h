//
//  NSArray+Convert.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 26/1/22.
//

#import <Foundation/Foundation.h>
#import <transport.h>

#import "bloblist.h"
#import "stringpair.h"
#import "stringlist.h"
#import "PEPIdentity+Convert.h"
#import "PEPMessage+Convert.h"

@class PEPMessage;
@class PEPIdentity;
@class PEPAttachment;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (PEPConvert)

// MARK: - NSArray <-> stringlist_t

+ (NSArray<NSString*> *)fromStringlist:(const stringlist_t * _Nonnull)stringList;

- (stringlist_t * _Nullable)toStringList;

// MARK: - NSArray <-> stringpair_list_t

+ (NSArray<NSArray<NSString*>*> *)fromStringPairlist:(const stringpair_list_t * _Nonnull)stringPairList;

- (stringpair_list_t * _Nullable)toStringPairList;


@end

NS_ASSUME_NONNULL_END
