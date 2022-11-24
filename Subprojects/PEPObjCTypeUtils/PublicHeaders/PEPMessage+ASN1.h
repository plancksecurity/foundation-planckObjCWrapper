//
//  PEPMessage+ASN1.h
//  pEpCC_macOS
//
//  Created by Dirk Zimmermann on 25.08.21.
//

#import <Foundation/Foundation.h>

@import PEPObjCTypes;

NS_ASSUME_NONNULL_BEGIN

/// Extensions for converting asn.1 to and from `PEPMessage`.
///
/// @see https://dev.pep.foundation/Engine/ASN1Message
@interface PEPMessage (ASN1)

/// Try to create a message from bytes, using asn.1.
+ (instancetype _Nullable)messageFromAsn1Data:(NSData *)asn1Data;

/// The message serialized to bytes, via asn.1.
///
/// @return The asn.1 encoded message bytes, or nil if encoding didn't work, and maybe on insufficient memory.
- (NSData * _Nullable)asn1Data;

@end

NS_ASSUME_NONNULL_END
