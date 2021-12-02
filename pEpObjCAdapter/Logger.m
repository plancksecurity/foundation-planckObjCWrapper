//
//  Logger.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 08.09.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#ifdef NO_TOOLBOX

#import "Logger.h"

@implementation Logger

+ (void)logInfoFilename:(const char *)filename
               function:(const char *)function
                   line:(NSInteger)line
                message:(NSString *)message
{
    [self internalLogFilename:filename function:function line:line message:message];
}

+ (void)logWarnFilename:(const char *)filename
               function:(const char *)function
                   line:(NSInteger)line
                message:(NSString *)message
{
    [self internalLogFilename:filename function:function line:line message:message];
}

+ (void)logErrorFilename:(const char *)filename
                function:(const char *)function
                    line:(NSInteger)line
                 message:(NSString *)message
{
    [self internalLogFilename:filename function:function line:line message:message];
}

+ (void)logErrorAndCrashFilename:(const char *)filename
                function:(const char *)function
                    line:(NSInteger)line
                 message:(NSString *)message
{
    [self internalLogFilename:filename function:function line:line message:message];
    //TODO: crash
}

+ (void)internalLogFilename:(const char *)filename
                function:(const char *)function
                    line:(NSInteger)line
                 message:(NSString *)message
{
    NSLog(@"%@-%@:%ld - %@",
          [NSString stringWithUTF8String:filename],
          [NSString stringWithUTF8String:function],
          (long)line,
          message);
}

@end
#endif
