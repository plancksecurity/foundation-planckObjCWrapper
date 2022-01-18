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

// MARK: - PEPMessage

+ (PEPMessage * _Nullable)pEpMessagefromStruct:(const message * _Nullable)msg;

+ (message * _Nullable)structFromPEPMessage:(PEPMessage *)pEpMessage;

+ (void)overWritePEPMessageObject:(PEPMessage *)pEpMessage
             withValuesFromStruct:(const message * _Nonnull)message;

+ (void)removeEmptyRecipientsFromPEPMessage:(PEPMessage *)pEpMessage;

+ (PEPMessage *)pEpMessageWithEmptyRecipientsRemovedFromPEPMessage:(PEPMessage *)pEpMessage;

// MARK: - PEPIdentity

+ (PEPIdentity * _Nullable)pEpIdentityfromStruct:(const pEp_identity * _Nonnull)identityStruct;

+ (pEp_identity *)structFromPEPIdentity:(PEPIdentity *)pEpIdentity;

+ (void)overWritePEPIdentityObject:(PEPIdentity *)pEpIdentity
              withValuesFromStruct:(const pEp_identity * _Nonnull)identityStruct;

// MARK: - NSArray <-> stringlist_t

+ (NSArray<NSString*> *)arrayFromStringlist:(const stringlist_t * _Nonnull)stringList;

+ (stringlist_t * _Nullable)arrayToStringList:(NSArray<NSString*> *)array;

// MARK: - NSArray <-> identity_list

+ (NSArray<PEPIdentity*> *)arrayFromIdentityList:(const identity_list *)identityList;

+ (identity_list * _Nullable)arrayToIdentityList:(NSArray<PEPIdentity*> *)array;

// MARK: - NSArray <-> stringpair_list_t

+ (NSArray<NSArray<NSString*>*> *)arrayFromStringPairlist:(const stringpair_list_t * _Nonnull)stringPairList;

+ (stringpair_list_t * _Nullable)arrayToStringPairlist:(NSArray<NSArray<NSString*>*> *)array;

// MARK: - NSArray<PEPAttachment*> <-> bloblist_t

+ (NSArray<PEPAttachment*> *)arrayFromBloblist:(const bloblist_t * _Nonnull)blobList;

+ (bloblist_t * _Nullable)arrayToBloblist:(NSArray<PEPAttachment*> *)array;

@end

NS_ASSUME_NONNULL_END
