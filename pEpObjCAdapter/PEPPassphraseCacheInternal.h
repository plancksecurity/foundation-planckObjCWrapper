//
//  PEPPassphraseCacheInternal.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 26.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPPassphraseCache (internal)

- (instancetype)initWithTimeout:(NSUInteger)timeout;

@end

NS_ASSUME_NONNULL_END
