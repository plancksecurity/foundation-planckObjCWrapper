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

@interface NSArray (PEPConvert)

// MARK: - NSArray <-> stringlist_t

+ (NSArray<NSString*> *)fromStringlist:(const stringlist_t * _Nonnull)stringList;

- (stringlist_t * _Nullable)toStringList;

// MARK: - NSArray <-> stringpair_list_t

+ (NSArray<NSArray<NSString*>*> *)fromStringPairlist:(const stringpair_list_t * _Nonnull)stringPairList;

- (stringpair_list_t * _Nullable)toStringPairList;

// MARK: - NSArray<PEPIdentity> <-> identity_list

+ (NSArray<PEPIdentity*> *)fromIdentityList:(identity_list *)identityList;

- (identity_list * _Nullable)toIdentityList;

// MARK: - NSArray<PEPAttachment> <-> bloblist_t

+ (NSArray<PEPAttachment*> *)fromBloblist:(const bloblist_t * _Nonnull)blobList;

- (bloblist_t * _Nullable)toBloblist;

@end

NS_ASSUME_NONNULL_END
