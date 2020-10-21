//
//  NSArray+Extension.h
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 03.05.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrayTake : NSObject

@property (nonatomic, readonly) NSArray * _Nonnull elements;
@property (nonatomic, readonly) NSArray * _Nonnull rest;

@end

@interface NSArray (Extension)

/**
 @Return The next count elements or nil, if less than that amount available.
 */
- (ArrayTake * _Nullable)takeOrNil:(NSInteger)count;

@end
