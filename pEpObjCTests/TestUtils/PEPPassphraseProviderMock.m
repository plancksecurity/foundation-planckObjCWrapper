//
//  PEPPassphraseProviderMock.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 09.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseProviderMock.h"

@interface PEPPassphraseProviderMock ()

/// Configure the passphrases which are supposed to come from the user.
@property (nonatomic) NSArray <NSString *> *passphrases;

/// Index to the passphrase in `passphrases` to be used next.
@property (nonatomic) NSUInteger passphraseIndex;

@end

@implementation PEPPassphraseProviderMock

- (instancetype)initWithPassphrases:(NSArray<NSString *> *)passphrases
{
    self = [super init];
    if (self) {
        _passphrases = passphrases;
    }
    return self;
}

- (void)passphraseRequired:(nonnull PEPPassphraseProviderCallback)completion {
    [self answerWithLatestPassphrase:completion];
}

- (void)passphraseTooLong:(nonnull PEPPassphraseProviderCallback)completion {
    self.passphraseTooLongWasCalled = YES;
    [self answerWithLatestPassphrase:completion];
}

- (void)wrongPassphrase:(nonnull PEPPassphraseProviderCallback)completion {
    [self answerWithLatestPassphrase:completion];
}

- (void)answerWithLatestPassphrase:(nonnull PEPPassphraseProviderCallback)completion
{
    if (self.passphrases.count > self.passphraseIndex) {
        NSString *newPassphrase = [self.passphrases objectAtIndex:self.passphraseIndex];
        self.passphraseIndex++;
        completion(newPassphrase);
    } else {
        completion(nil);
    }
}

@end
