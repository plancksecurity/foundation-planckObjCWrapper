//
//  NSArray+Engine.h
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "stringlist.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Engine)

+ (NSArray * _Nonnull)arrayFromStringlist:(stringlist_t * _Nonnull)stringList;

- (stringlist_t * _Nullable)toStringList;

@end

NS_ASSUME_NONNULL_END
