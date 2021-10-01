//
//  Connector.m
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 11.08.21.
//

#import "Connector.h"

#import "StreamRunLoop.h"

@interface Connector ()

@property (nonatomic) StreamRunLoop *stream;
@property (nonatomic) dispatch_group_t dispatchGroup;

@end

@implementation Connector

- (void)connectWithHostname:(NSString *)hostname port:(uint32_t)port
{
    self.stream = [[StreamRunLoop alloc] initWithHostname:hostname port:port];
    [self.stream connectWithDelegate:self];
    self.dispatchGroup = dispatch_group_create();
    dispatch_group_enter(self.dispatchGroup);
    dispatch_group_wait(self.dispatchGroup, DISPATCH_TIME_FOREVER);
}

#pragma mark - StreamRunLoopDelegate

- (void)connectionEstablished
{
    [self.stream close];
}

- (void)threadFinished
{
    dispatch_group_leave(self.dispatchGroup);
}

@end
