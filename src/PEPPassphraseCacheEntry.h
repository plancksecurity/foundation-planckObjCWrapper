//
//  PEPPassphraseCacheEntry.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 26.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPPassphraseCacheEntry : NSObject

@property (nonatomic) NSString *passphrase;

/// The date the passphrase was last added or successfully used.
@property (nonatomic) NSDate *dateAdded;

- (instancetype)initWithPassphrase:(NSString *)passphrase;

@end

NS_ASSUME_NONNULL_END
