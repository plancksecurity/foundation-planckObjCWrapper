//
//  PEPError.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 09.02.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString * _Nonnull const kpEpFunctionName;

@interface PEPError : NSError

+ (instancetype _Nonnull)errorWithStatusCode:(NSInteger)statusCode
                                functionName:(NSString * _Nullable)functionName;

- (instancetype _Nonnull)initWithStatusCode:(NSInteger)statusCode
                               functionName:(NSString * _Nullable)functionName;

@end
