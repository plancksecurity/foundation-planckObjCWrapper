//
//  PEPAutoPointer+Message.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 24.11.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPAutoPointer.h"

#import "message.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPAutoPointer (Message)

- (instancetype)initWithMessage:(message *)message;

@end

NS_ASSUME_NONNULL_END
