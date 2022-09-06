//
//  PEPMediaKeyPair.h
//  PEPObjCTypes
//
//  Created by Dirk Zimmermann on 06.09.22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// Models the input to the engine's `config_media_keys`.
/// @see https://dev.pep.foundation/Engine/Media%20keys
@interface PEPMediaKeyPair : NSObject

/// The media key pattern.
@property (nonatomic, readonly) NSString *pattern;

/// The fingerprint for this media key entry.
@property (nonatomic, readonly) NSString *fingerprint;

- (instancetype)initWithPattern:(NSString *)pattern fingerprint:(NSString *)fingerprint;

@end

NS_ASSUME_NONNULL_END
