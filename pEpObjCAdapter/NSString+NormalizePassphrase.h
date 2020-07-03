//
//  NSString+NormalizePassphrase.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 01.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (NormalizePassphrase)

/// Returns a normalized (unicode NFC) version of the given passphrase,
/// checking for length as well.
/// @param error The (optional) error, maybe PEPAdapterErrorPassphraseTooLong
/// with a domain of PEPObjCAdapterErrorDomain.
/// @Return `nil` if an error occurred.
- (NSString * _Nullable)normalizedPassphraseWithError:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
