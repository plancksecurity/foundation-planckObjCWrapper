//
//  PEPPassphraseProviderMock.h
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 09.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPPassphraseProviderMock : NSObject<PEPPassphraseProviderProtocol>

@property (nonatomic) BOOL passphraseRequiredWasCalled;
@property (nonatomic) BOOL passphraseTooLongWasCalled;

- (instancetype)initWithPassphrases:(NSArray<NSString *> *)passphrases;

@end

NS_ASSUME_NONNULL_END
