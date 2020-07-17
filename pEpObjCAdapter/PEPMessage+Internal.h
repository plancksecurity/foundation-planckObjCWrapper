//
//  PEPMessage+Internal.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 17.07.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <PEPObjCAdapterFramework/PEPObjCAdapterFramework.h>

#import "message.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPMessage (Internal)

- (void)replaceWithMessage:(message *)message;

@end

NS_ASSUME_NONNULL_END
