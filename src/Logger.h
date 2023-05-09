//
//  Logger.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 05.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#ifndef Logger_h
#define Logger_h

#import "Platform.h"

#ifdef IS_IOS_BUILD
    #import <PlanckToolboxForExtensions/PlanckToolboxForExtensions-Swift.h>
    #import <PlanckToolboxForExtensions/PEPLogger.h>
#else
    #ifndef NO_TOOLBOX
        #import "PEPToolbox_macOS-Swift.h"
        #import "PEPLogger.h"
    #endif
#endif


#ifdef NO_TOOLBOX
/// This is a copy of the iOSToolbox PEPLogger.h interface. Providing a iOSToolbox independend
/// logging impl.We must not use (at least currently) the iOS toolbox for Linux builds.
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Logger : NSObject
+ (void)logInfoFilename:(const char *)filename
               function:(const char *)function
                   line:(NSInteger)line
                 message:(NSString *)message;

+ (void)logWarnFilename:(const char *)filename
               function:(const char *)function
                   line:(NSInteger)line
                message:(NSString *)message;

+ (void)logErrorFilename:(const char *)filename
                function:(const char *)function
                    line:(NSInteger)line
                 message:(NSString *)message;

+ (void)logErrorAndCrashFilename:(const char *)filename
                        function:(const char *)function
                            line:(NSInteger)line
                         message:(NSString *)message;
@end

#define LogInfo(...) [Logger logInfoFilename:__FILE__ function:__FUNCTION__ line:__LINE__ message:[NSString stringWithFormat:__VA_ARGS__]];

#define LogWarn(...) [Logger logWarnFilename:__FILE__ function:__FUNCTION__ line:__LINE__ message:[NSString stringWithFormat:__VA_ARGS__]];

#define LogError(...) [Logger logErrorFilename:__FILE__ function:__FUNCTION__ line:__LINE__ message:[NSString stringWithFormat:__VA_ARGS__]];

#define LogError(...) [Logger logErrorFilename:__FILE__ function:__FUNCTION__ line:__LINE__ message:[NSString stringWithFormat:__VA_ARGS__]];

#define LogErrorAndCrash(...) [Logger logErrorAndCrashFilename:__FILE__ function:__FUNCTION__ line:__LINE__ message:[NSString stringWithFormat:__VA_ARGS__]];

NS_ASSUME_NONNULL_END

#endif



#endif /* Logger_h */


