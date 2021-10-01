//
//  StreamRunLoopDelegate.h
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 11.08.21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol StreamRunLoopDelegate

- (void)connectionEstablished;
- (void)threadFinished;

@end

NS_ASSUME_NONNULL_END
