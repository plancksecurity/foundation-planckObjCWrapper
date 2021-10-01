//
//  Connector.h
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 11.08.21.
//

#import <Foundation/Foundation.h>

#import "StreamRunLoopDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface Connector : NSObject <StreamRunLoopDelegate>

- (void)connectWithHostname:(NSString *)hostname port:(uint32_t)port;

@end

NS_ASSUME_NONNULL_END
