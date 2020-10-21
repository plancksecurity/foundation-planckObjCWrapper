//
//  NSArray+PEP.h
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "message_api.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (PEP)

+ (NSArray * _Nonnull)arrayFromStringlist:(stringlist_t * _Nonnull)stringList;

@end

NS_ASSUME_NONNULL_END
