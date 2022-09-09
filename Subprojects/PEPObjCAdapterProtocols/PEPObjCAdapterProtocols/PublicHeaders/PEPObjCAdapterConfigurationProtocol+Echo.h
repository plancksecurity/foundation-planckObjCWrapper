//
//  PEPObjCAdapterConfigurationProtocol+Echo.h
//  PEPObjCAdapterProtocols
//
//  Created by Dirk Zimmermann on 08.09.22.
//

#ifndef PEPObjCAdapterConfigurationProtocol_Echo_h
#define PEPObjCAdapterConfigurationProtocol_Echo_h

/// @see https://dev.pep.foundation/Engine/Echo%20Protocol
@protocol PEPObjCAdapterEchoConfigurationProtocol <NSObject>

/// Enables or disable the use of the echo protocol.
///
/// The protocol is enabled by default.
+ (void)setEchoProtocolEnabled:(BOOL)enabled;

/// Enables or disables pings for the engine's `outgoing_message_rating_preview`.
///
/// Ping messages from outgoing_message_rating_preview are enabled by default.
+ (void)setEchoInOutgoingMessageRatingPreviewEnabled:(BOOL)enabled;

@end

#endif /* PEPObjCAdapterConfigurationProtocol_Echo_h */
