//
//  NSInvocation+PEPThreading.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 10.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "NSInvocation+PEPThreading.h"

#import "PEPInvocationArgumentWrapper.h"

@implementation NSInvocation (PEPThreading)

+ (instancetype _Nullable)invocationForStaticMethod:(SEL _Nonnull)selector
                                            onClass:(Class _Nonnull)theClass
                                      withArguments:(NSArray<PEPInvocationArgumentWrapper*> * _Nullable)args
{
    //    SEL selector = NSSelectorFromString(@"someSelector");
    if ([theClass respondsToSelector:selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [theClass instanceMethodSignatureForSelector:selector]];
        [invocation setTarget:theClass];                    // index 0
        [invocation setSelector:selector];               // index 1
        NSInteger argIdx = 1;
        for (int i = 0; i < args.count; ++i) {
            ++argIdx;                                   // index 2,  ...
            PEPInvocationArgumentWrapper *arg = args[i];
            if (arg.type == typeObject) {
                id value = arg.value;
                [invocation setArgument:&value atIndex:argIdx];
            } else if (arg.type == typeInteger) {
                NSNumber *valueObj = arg.value;
                NSInteger value = valueObj.integerValue;
                [invocation setArgument:&value atIndex:argIdx];
            }
        }
        [invocation retainArguments];

        return invocation;
    }
    return nil;
}

- (void)invokeOnThread:(NSThread * _Nonnull)thread withTarget:(id _Nonnull)target
{
    [self performSelector:@selector(invokeWithTarget:)
                 onThread:thread
               withObject:target
            waitUntilDone:YES];
}

- (NSInteger)invokeWithIntReturnValueOnThread:(NSThread * _Nonnull)thread
                                   withTarget:(id _Nonnull)target
{
    [self performSelector:@selector(invokeWithTarget:)
                 onThread:thread
               withObject:target
            waitUntilDone:YES];
    NSInteger returnValue;
    [self getReturnValue:&returnValue];

    return returnValue;
}

@end
