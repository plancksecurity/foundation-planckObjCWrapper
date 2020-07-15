//
//  PEPPassphraseProviderUIMock.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 15.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseProviderUIMock.h"

#import <UIKit/UIKit.h>

@implementation PEPPassphraseProviderUIMock

- (void)passphraseRequired:(nonnull PEPPassphraseProviderCallback)completion {
    [self askUserForPassphrase:completion];
}

- (void)passphraseTooLong:(nonnull PEPPassphraseProviderCallback)completion {
    [self askUserForPassphrase:completion];
}

- (void)wrongPassphrase:(nonnull PEPPassphraseProviderCallback)completion {
    [self askUserForPassphrase:completion];
}

- (void)answerWithLatestPassphrase:(nonnull PEPPassphraseProviderCallback)completion
{
    [self askUserForPassphrase:completion];
}

- (void)askUserForPassphrase:(nonnull PEPPassphraseProviderCallback)completion
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Passphrase"
                                message:@"Passphrase needed"
                                preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
}

@end
