//
//  PEPObjCTypeConversionUtil.h
//  PEPObjCTypeUtils
//
//  Created by Andreas Buff on 04.11.21.
//

#import <Foundation/Foundation.h>

#import "transport.h"

@class PEPTransport;
@class PEPMessage;
@class PEPIdentity;
@class PEPAttachment;

NS_ASSUME_NONNULL_BEGIN

@interface PEPObjCTypeConversionUtil : NSObject

// MARK: - PEPTransport

+ (PEPTransport * _Nullable)pEpTransportfromStruct:(PEP_transport_t * _Nonnull)transportStruct;

+ (PEP_transport_t *)structFromPEPTransport:(PEPTransport *)pEpTransport;

+ (void)overWritePEPTransportObject:(PEPTransport *)pEpTransport
               withValuesFromStruct:(PEP_transport_t * _Nonnull)transportStruct;

// MARK: - PEPMessage

+ (PEPMessage * _Nullable)pEpMessagefromStruct:(message * _Nullable)msg;

+ (message * _Nullable)structFromPEPMessage:(PEPMessage *)pEpMessage;

+ (void)overWritePEPMessageObject:(PEPMessage *)pEpMessage
             withValuesFromStruct:(message * _Nonnull)message;

+ (void)removeEmptyRecipientsFromPEPMessage:(PEPMessage *)pEpMessage;

+ (PEPMessage *)pEpMessageWithEmptyRecipientsRemovedFromPEPMessage:(PEPMessage *)pEpMessage;

// MARK: - PEPIdentity

+ (PEPIdentity * _Nullable)pEpIdentityfromStruct:(pEp_identity * _Nonnull)identityStruct;

+ (pEp_identity *)structFromPEPIdentity:(PEPIdentity *)pEpIdentity;

+ (void)overWritePEPIdentityObject:(PEPIdentity *)pEpIdentity
              withValuesFromStruct:(pEp_identity * _Nonnull)identityStruct;

// MARK: - NSArray <-> stringlist_t

+ (NSArray<NSString*> *)arrayFromStringlist:(stringlist_t * _Nonnull)stringList;

+ (stringlist_t * _Nullable)arrayToStringList:(NSArray<NSString*> *)array;

// MARK: - NSArray <-> identity_list

+ (NSArray<PEPIdentity*> *)arrayFromIdentityList:(identity_list *)identityList;

+ (identity_list * _Nullable)arrayToIdentityList:(NSArray<PEPIdentity*> *)array;

// MARK: - NSArray <-> stringpair_list_t

+ (NSArray<NSArray<NSString*>*> *)arrayFromStringPairlist:(stringpair_list_t * _Nonnull)stringPairList;

+ (stringpair_list_t * _Nullable)arrayToStringPairlist:(NSArray<NSArray<NSString*>*> *)array;

// MARK: - NSArray<PEPAttachment*> <-> bloblist_t

+ (NSArray<PEPAttachment*> *)arrayFromBloblist:(bloblist_t * _Nonnull)blobList;

+ (bloblist_t * _Nullable)arrayToBloblist:(NSArray<PEPAttachment*> *)array;

@end

NS_ASSUME_NONNULL_END
