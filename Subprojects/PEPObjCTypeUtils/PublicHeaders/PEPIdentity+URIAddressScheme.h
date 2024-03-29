//
//  PEPIdentity+URIAddressScheme.h
//  pEpObjCAdapter
//
//  Created by Martín Brude on 9/2/22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PEPObjCTypes;

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity (URIAddressScheme)

/// Instanciate an Identity with the given parameters.
/// There is no validation.
///
/// @param userID The user id. 
/// @param scheme The communication scheme.
/// @param ipV4 Valid IPv4 must be passed.
/// @param port The port.
- (nonnull instancetype)initWithUserID:(NSString *)userID
                                scheme:(NSString *)scheme
                                  ipV4:(NSString *)ipV4
                                  port:(NSUInteger)port;

/// Instanciate an Identity with the given parameters.
/// There is no validation.
///
/// @param userID The user id.
/// @param scheme The communication scheme.
/// @param ipV6 Valid IPv6 must be passed.
/// @param port The port.
- (nonnull instancetype)initWithUserID:(NSString *)userID
                                scheme:(NSString *)scheme
                                  ipV6:(NSString *)ipV6
                                  port:(NSUInteger)port;

/// Get the IPV4 from the address of the identity if it's IPV4, otherwise will return nil.
/// If the address does not respect the pEp scheme will return nil.
///
/// For example:
/// from the address "sctp:1.2.3.4:666" it will return '1.2.3.4'
/// from the address "sctp:[1::2::3::4::5::6::7::8]:666" it will return nil
/// from "some.address@pep.security" will return nil.
///
/// @return the IPV4
- (NSString * _Nullable)getIPV4;

/// Get the IPV6 from the address of the identity if it's IPV6, otherwise will return nil.
/// If the address does not respect the pEp scheme will return nil.
///
/// For example:
/// from the address "sctp:[1::2::3::4::5::6::7::8]:666" it will return '1::2::3::4::5::6::7::8'
/// from the address "sctp:1.2.3.4:666" it will return nil
/// from "some.address@pep.security" will return nil.
///
/// @return the IPV6
- (NSString * _Nullable)getIPV6;

/// Get the port from the address of the identity.
/// If the address does not respect the pEp scheme will return 0.
///
/// For example:
/// from the address "sctp:1.2.3.4:666" it will return '666'
/// from "some.address@pep.security" will return nil`.
///
/// @return the port
- (NSNumber * _Nullable)getPort;

/// Get the scheme from the address of the identity if can find it.
/// If the address does not respect the pEp scheme will return nil.
/// Otherwise will return nil.
///
/// For example:
/// from the address "sctp:1.2.3.4:666" it will return 'sctp'
///
/// @return the scheme
- (NSString * _Nullable)getScheme;

@end

NS_ASSUME_NONNULL_END
