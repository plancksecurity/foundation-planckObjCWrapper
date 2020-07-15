//
//  PEPPassphraseProviderUIMock.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 15.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseProviderUIMock.h"

@implementation PEPPassphraseProviderUIMock

- (void)passphraseRequired:(nonnull PEPPassphraseProviderCallback)completion {
}

- (void)passphraseTooLong:(nonnull PEPPassphraseProviderCallback)completion {
}

- (void)wrongPassphrase:(nonnull PEPPassphraseProviderCallback)completion {
}

- (void)answerWithLatestPassphrase:(nonnull PEPPassphraseProviderCallback)completion
{
}

@end
