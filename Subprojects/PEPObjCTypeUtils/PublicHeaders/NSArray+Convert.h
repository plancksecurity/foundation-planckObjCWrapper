//
//  NSArray+Convert.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 26/1/22.
//

#import <Foundation/Foundation.h>
#import <transport.h>

@class PEPMessage;
@class PEPIdentity;
@class PEPAttachment;

NS_ASSUME_NONNULL_BEGIN


@interface NSArray (Convert)

// MARK: - NSArray <-> stringlist_t

+ (NSArray<NSString*> *)arrayFromStringlist:(const stringlist_t * _Nonnull)stringList;

+ (stringlist_t * _Nullable)arrayToStringList:(NSArray<NSString*> *)array;

// MARK: - NSArray <-> stringpair_list_t

+ (NSArray<NSArray<NSString*>*> *)arrayFromStringPairlist:(const stringpair_list_t * _Nonnull)stringPairList;

+ (stringpair_list_t * _Nullable)arrayToStringPairlist:(NSArray<NSArray<NSString*>*> *)array;

@end

NS_ASSUME_NONNULL_END
