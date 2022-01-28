//
//  PEPIdentity+PEPConvert.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 25/1/22.
//

#import <Foundation/Foundation.h>
#import "PEPIdentity.h"
#import <transport.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity (PEPConvert)

+ (PEPIdentity * _Nullable)fromStruct:(const pEp_identity * _Nonnull)identityStruct;

- (pEp_identity *)toStruct;

@end

NS_ASSUME_NONNULL_END
