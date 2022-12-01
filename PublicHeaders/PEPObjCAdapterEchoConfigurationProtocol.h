//
//  PEPObjCAdapterEchoConfigurationProtocol.h
//  PEPObjCAdapterProtocols
//
//  Created by Dirk Zimmermann on 08.09.22.
//

#ifndef PEPObjCAdapterConfigurationProtocol_Echo_h
#define PEPObjCAdapterConfigurationProtocol_Echo_h

#import "PEPNotifyHandshakeDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// Echo protocol configuration across all sessions, including existing ones
/// that get re-used.
///
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

/// Sets or unsets the global delegate for outgoing rating changes, that usually gets triggered on
/// decrypting pong messages (part of the echo protocol) via a handshake notification with the reason
/// of `SYNC_NOTIFY_OUTGOING_RATING_CHANGE`.
///
/// @note Even though the engine, and consequently the adapter, reuse handshake notifications
/// for rating changes, there is no actual connection between the two.
+ (void)setEchoOutgoingRatingChangeDelegate:(id<PEPNotifyHandshakeDelegate> _Nullable)delegate;

@end

NS_ASSUME_NONNULL_END

#endif /* PEPObjCAdapterConfigurationProtocol_Echo_h */
