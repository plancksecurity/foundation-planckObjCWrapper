//
//  PEPInternalSession+PassphraseCache.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 26.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPInternalSession+PassphraseCache.h"

#import "pEpEngine.h"

#import "PEPPassphraseCache.h"
#import "PEPObjCAdapter+ReadConfig.h"
#import "NSString+NormalizePassphrase.h"
#import "PEPPassphraseUtil.h"

@implementation PEPInternalSession (PassphraseCache)

- (PEPStatus)runWithPasswords:(PEP_STATUS (^)(PEP_SESSION session))block
{
    return [PEPPassphraseUtil runWithPasswordsSession:self.session block:block];
}

@end
