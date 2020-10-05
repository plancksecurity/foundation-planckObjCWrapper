//
//  Logger.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 05.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#ifndef Logger_h
#define Logger_h

#import <pEpIOSToolbox/pEpIOSToolbox-Swift.h>

#define LogInfo(...) [[Log shared] \
 logInfoWithMessage:[NSString stringWithFormat:__VA_ARGS__] \
 function:[NSString stringWithUTF8String:__FUNCTION__] \
 filePath:[NSString stringWithUTF8String:__FILE__] \
 fileLine:__LINE__];
#define LogWarn(...) [[Log shared] \
logWarnWithMessage:[NSString stringWithFormat:__VA_ARGS__] \
function:[NSString stringWithUTF8String:__FUNCTION__] \
filePath:[NSString stringWithUTF8String:__FILE__] \
fileLine:__LINE__];
#define LogError(...) [[Log shared] \
logErrorWithMessage:[NSString stringWithFormat:__VA_ARGS__] \
function:[NSString stringWithUTF8String:__FUNCTION__] \
filePath:[NSString stringWithUTF8String:__FILE__] \
fileLine:__LINE__];

#endif /* Logger_h */