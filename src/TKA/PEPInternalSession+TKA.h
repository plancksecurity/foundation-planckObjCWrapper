//
//  PEPInternalSession+TKA.h
//  PEPObjCAdapter_iOS
//
//  Created by Dirk Zimmermann on 18.01.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPInternalSession.h"

#import "PEPTKADelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPInternalSession (TKA)

- (PEPStatus)tkaSubscribeKeychangeDelegate:(id<PEPTKADelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
