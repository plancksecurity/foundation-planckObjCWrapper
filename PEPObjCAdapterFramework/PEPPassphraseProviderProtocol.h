//
//  PEPPassphraseProviderProtocol.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 08.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Callback an app can use to provide a passphrase to the adapter after user input
typedef void (^PEPPassphraseProviderCallback)(NSString * _Nullable passphrase);

@protocol PEPPassphraseProviderProtocol <NSObject>

@end

NS_ASSUME_NONNULL_END
