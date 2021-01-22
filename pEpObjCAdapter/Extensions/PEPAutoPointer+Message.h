//
//  PEPAutoPointer+Message.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 02.12.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPAutoPointer.h"

#import "message.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPAutoPointer (Message)

/// Specialized version that will auto-release/free the given message struct when it goes out of scope.
+ (instancetype)autoPointerWithMessage:(message *)message;

/// Specialized version that will auto-release/free the given message struct when it goes out of scope.
- (instancetype)initWithMessage:(message *)message;

@end

NS_ASSUME_NONNULL_END
