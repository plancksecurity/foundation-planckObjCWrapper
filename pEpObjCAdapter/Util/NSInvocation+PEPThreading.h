//
//  NSInvocation+PEPThreading.h
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 10.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

//BUFF: obsolete?
#import <Foundation/Foundation.h>
@class PEPInvocationArgumentWrapper;

@interface NSInvocation (PEPThreading)

+ (instancetype _Nullable)invocationForStaticMethod:(SEL _Nonnull)selector
                                            onClass:(Class _Nonnull)theClass
                                      withArguments:(NSArray<PEPInvocationArgumentWrapper*> * _Nullable)args;

- (void)invokeOnThread:(NSThread * _Nonnull)thread
            withTarget:(id _Nonnull)target;

- (NSInteger)invokeWithIntReturnValueOnThread:(NSThread * _Nonnull)thread
                                   withTarget:(id _Nonnull)target;

@end
