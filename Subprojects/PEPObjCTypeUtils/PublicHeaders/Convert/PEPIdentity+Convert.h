//
//  PEPIdentity+Convert.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 25/1/22.
//

#import <Foundation/Foundation.h>
#import "PEPIdentity.h"
#import <transport.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity (Convert)

+ (PEPIdentity * _Nullable)pEpIdentityfromStruct:(const pEp_identity * _Nonnull)identityStruct;

+ (pEp_identity *)structFromPEPIdentity:(PEPIdentity *)pEpIdentity;

+ (void)overWritePEPIdentityObject:(PEPIdentity *)pEpIdentity
              withValuesFromStruct:(const pEp_identity * _Nonnull)identityStruct;

+ (NSArray<PEPIdentity*> *)arrayFromIdentityList:(identity_list *)identityList;

+ (identity_list * _Nullable)arrayToIdentityList:(NSArray<PEPIdentity*> *)array;

@end

NS_ASSUME_NONNULL_END
