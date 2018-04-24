//
//  NSMutableDictionary+PEP.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 24.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "message.h"

@interface NSMutableDictionary (PEP)

/**
 Replaces all content with `message`.
 */
- (void)replaceWithMessage:(message *)message;

@end
