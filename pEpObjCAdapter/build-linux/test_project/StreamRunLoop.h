//
//  StreamRunLoop.h
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 10.08.21.
//

#import <Foundation/Foundation.h>

#import "StreamRunLoopDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface StreamRunLoop : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id<StreamRunLoopDelegate> delegate;

- (instancetype)initWithHostname:(NSString *)hostname port:(uint32_t)port;

- (void)connectWithDelegate:(id<StreamRunLoopDelegate>)delegate;
- (void)close;

@end

NS_ASSUME_NONNULL_END
