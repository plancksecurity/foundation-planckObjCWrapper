//
//  PEPTransport+Engine.h
//
//  Created by Andreas Buff on 16.08.21.
//

#import <Foundation/Foundation.h>

#import "PEPTransport.h"

#import "transport.h"

NS_ASSUME_NONNULL_BEGIN

/// Intentinally unimplemented as currently unused. See PEPCCTransport.h
@interface PEPTransport (Engine)


+ (instancetype _Nullable)fromStruct:(PEP_transport_t * _Nonnull)transportStruct;

- (PEP_transport_t *)toStruct;
- (void)overWriteFromStruct:(PEP_transport_t * _Nonnull)transportStruct;

@end

NS_ASSUME_NONNULL_END

