//
//  PEPIdentity+PEPConvert.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 25/1/22.
//

#import <Foundation/Foundation.h>

#import <transport.h>

@import PEPObjCTypes_iOS;

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity (PEPConvert)

+ (PEPIdentity * _Nullable)fromStruct:(const pEp_identity * _Nonnull)identityStruct;

- (pEp_identity *)toStruct;

+ (void)overwritePEPIdentityObject:(PEPIdentity *)pEpIdentity withValuesFromStruct:(const pEp_identity * _Nonnull)identityStruct;

@end

NS_ASSUME_NONNULL_END
