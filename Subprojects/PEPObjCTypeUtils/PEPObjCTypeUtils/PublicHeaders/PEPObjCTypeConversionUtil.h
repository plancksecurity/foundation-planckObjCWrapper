//
//  PEPObjCTypeConversionUtil.h
//  PEPObjCTypeUtils
//
//  Created by Andreas Buff on 04.11.21.
//

#import <Foundation/Foundation.h>

#import "transport.h"

@class PEPTransport;

NS_ASSUME_NONNULL_BEGIN

@interface PEPObjCTypeConversionUtil : NSObject

// MARK: - PEPTransport

+ (PEPTransport * _Nullable)pEpTransportfromStruct:(PEP_transport_t * _Nonnull)transportStruct;

+ (PEP_transport_t *)structFromPEPTransport:(PEPTransport *)pEpTransport;

+ (void)overWritePEPTransportObject:(PEPTransport *)pEpTransport
               withValuesFromStruct:(PEP_transport_t * _Nonnull)transportStruct;

@end

NS_ASSUME_NONNULL_END
