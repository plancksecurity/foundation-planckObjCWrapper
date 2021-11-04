//
//  PEPObjCTypeConversionUtil.m
//  PEPObjCTypeUtils
//
//  Created by Andreas Buff on 04.11.21.
//

#import "PEPObjCTypeConversionUtil.h"

#import "PEPTransport.h"

@implementation PEPObjCTypeConversionUtil

// MARK: - PEPTransport

+ (PEPTransport * _Nullable)pEpTransportfromStruct:(PEP_transport_t * _Nonnull)transportStruct
{
    PEPTransport *result = nil;
    NSAssert(false, @"unimplemented stub");
    return result;
}

+ (PEP_transport_t *)structFromPEPTransport:(PEPTransport *)pEpTransport
{
    PEP_transport_t *transportStruct = NULL;
    NSAssert(false, @"unimplemented stub");
    return transportStruct;
}

+ (void)overWritePEPTransportObject:(PEPTransport *)pEpTransport
               withValuesFromStruct:(PEP_transport_t * _Nonnull)transportStruct
{
    NSAssert(false, @"unimplemented stub");
}
@end
