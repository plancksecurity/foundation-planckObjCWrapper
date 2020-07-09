//
//  PEPPassphraseProviderMock.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 09.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseProviderMock.h"

@implementation PEPPassphraseProviderMock

- (void)passphraseRequired:(nonnull PEPPassphraseProviderCallback)completion {
    completion(nil);
}

- (void)passphraseTooLong:(nonnull PEPPassphraseProviderCallback)completion {
    completion(nil);
}

- (void)wrongPassphrase:(nonnull PEPPassphraseProviderCallback)completion {
    completion(nil);
}

@end
