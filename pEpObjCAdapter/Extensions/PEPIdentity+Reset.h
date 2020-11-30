//
//  PEPIdentity+Reset.h
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 05.11.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PEPObjCAdapterTypesFramework/PEPObjCAdapterTypesFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity (Reset)

/// Puts all properties into a default/nil state.
- (void)reset;

@end

NS_ASSUME_NONNULL_END
