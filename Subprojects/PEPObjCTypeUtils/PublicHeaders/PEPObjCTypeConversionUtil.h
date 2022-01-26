//
//  PEPObjCTypeConversionUtil.h
//  PEPObjCTypeUtils
//
//  Created by Andreas Buff on 04.11.21.
//

#import <Foundation/Foundation.h>

#import <transport.h>

@class PEPMessage;
@class PEPIdentity;
@class PEPAttachment;

NS_ASSUME_NONNULL_BEGIN

@interface PEPObjCTypeConversionUtil : NSObject

// MARK: - NSArray <-> stringlist_t

+ (NSArray<NSString*> *)arrayFromStringlist:(const stringlist_t * _Nonnull)stringList;

+ (stringlist_t * _Nullable)arrayToStringList:(NSArray<NSString*> *)array;

// MARK: - NSArray <-> stringpair_list_t

+ (NSArray<NSArray<NSString*>*> *)arrayFromStringPairlist:(const stringpair_list_t * _Nonnull)stringPairList;

+ (stringpair_list_t * _Nullable)arrayToStringPairlist:(NSArray<NSArray<NSString*>*> *)array;

@end

NS_ASSUME_NONNULL_END
