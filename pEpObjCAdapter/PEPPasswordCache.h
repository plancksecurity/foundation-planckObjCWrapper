//
//  PEPPasswordCache.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 25.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPPasswordCache : NSObject

/// Timeout of passwords in seconds, the default being 10 minutes.
@property (nonatomic) NSUInteger timeout;

/// Add a new password.
- (void)addPassword:(NSString *)password;

/// Retrieve the current list of cached passwords, including the empty one.
- (NSArray *)passwords;

@end

NS_ASSUME_NONNULL_END
