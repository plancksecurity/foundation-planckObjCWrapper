//
//  PEPPassphraseCacheEntry.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 26.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseCacheEntry.h"

@implementation PEPPassphraseCacheEntry

- (instancetype)initPassword:(NSString *)password
{
    self = [super init];
    if (self) {
        self.password = password;
        self.dateAdded = [NSDate date];
    }
    return self;
}

@end
