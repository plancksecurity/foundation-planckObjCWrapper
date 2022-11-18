//
//  PEPObjCAdapterMediaKeysConfigurationProtocol.h
//  PEPObjCAdapterProtocols
//
//  Created by Dirk Zimmermann on 15.09.22.
//

#ifndef PEPObjCAdapterConfigurationProtocol_MediaKeys_h
#define PEPObjCAdapterConfigurationProtocol_MediaKeys_h

@class PEPMediaKeyPair;

NS_ASSUME_NONNULL_BEGIN

/// Media keys configuration across all sessions, including existing ones.
///
/// @see https://dev.pep.foundation/Engine/Media%20keys
@protocol PEPObjCAdapterMediaKeysConfigurationProtocol <NSObject>

+ (void)configureMediaKeys:(NSArray<PEPMediaKeyPair *> *)mediaKeys;

@end

NS_ASSUME_NONNULL_END

#endif /* PEPObjCAdapterConfigurationProtocol_MediaKeys_h */
