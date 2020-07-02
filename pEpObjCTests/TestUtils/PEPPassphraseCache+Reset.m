//
//  PEPPassphraseCache+Reset.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 02.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseCache+Reset.h"

extern PEPPassphraseCache * _Nullable g_passphraseCache;

@implementation PEPPassphraseCache (Reset)

+ (void)reset
{
    g_passphraseCache = [[PEPPassphraseCache alloc] init];
}

@end
