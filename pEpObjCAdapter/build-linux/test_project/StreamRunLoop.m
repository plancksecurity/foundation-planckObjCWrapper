//
//  StreamRunLoop.m
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 10.08.21.
//

#import "StreamRunLoop.h"

@interface StreamRunLoop ()

@property (atomic, strong) NSString *name;
@property (atomic) uint32_t port;
@property (atomic, strong, nullable) NSInputStream *readStream;
@property (atomic, strong, nullable) NSOutputStream *writeStream;
@property (nullable, strong) NSThread *backgroundThread;
@property (atomic) BOOL connected;
@property (atomic) BOOL isGettingClosed;
@property (atomic, strong) NSMutableSet<NSStream *> *openConnections;

@end

@implementation StreamRunLoop

- (instancetype)initWithHostname:(NSString *)hostname port:(uint32_t)port
{
    self = [super init];
    if (self) {
        _name = hostname;
        _port = port;
        _openConnections = [NSMutableSet new];
    }
    return self;
}

- (void)connectWithDelegate:(id<StreamRunLoopDelegate>)delegate
{
    self.delegate = delegate;

    self.backgroundThread = [[NSThread alloc]
                             initWithTarget:self
                             selector:@selector(connectInBackgroundAndStartRunLoop)
                             object:nil];
    self.backgroundThread.name = [NSString
                                  stringWithFormat:@"CWTCPConnection %@:%d 0x%lu",
                                  self.name,
                                  self.port,
                                  (unsigned long) self.backgroundThread];
    [self.backgroundThread start];
}

- (void)connectInBackgroundAndStartRunLoop
{
    NSInputStream *inputStream = nil;
    NSOutputStream *outputStream = nil;

    NSHost *host = [NSHost hostWithName:self.name];
    [NSStream getStreamsToHost:host
                          port:self.port
                   inputStream:&inputStream
                  outputStream:&outputStream];

    if (inputStream == nil || outputStream == nil) {
        NSLog(@"No input or output stream");
        [self close];
    }

    self.readStream = inputStream;
    self.writeStream = outputStream;

    [self setupStream:self.readStream];
    [self setupStream:self.writeStream];

    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    while (1) {
        if ( [NSThread currentThread].isCancelled ) {
            break;
        }
        @autoreleasepool {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]];
        }
    }
    self.backgroundThread = nil;
    [self.delegate threadFinished];
}

- (void)close
{
    [self closeAndRemoveStream:self.readStream];
    [self closeAndRemoveStream:self.writeStream];
    self.connected = NO;
    self.isGettingClosed = YES;
    [self cancelBackgroundThread];
}

- (void)setupStream:(NSStream *)stream
{
    stream.delegate = self;
    [stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [stream open];
}

- (void)closeAndRemoveStream:(NSStream *)stream
{
    if (stream) {
        [stream close];
        [self.openConnections removeObject:stream];
        [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        if (stream == self.readStream) {
            self.readStream = nil;
        } else if (stream == self.writeStream) {
            self.writeStream = nil;
        }
    }
}

- (void)cancelNoop
{
}

- (void)cancelBackgroundThread
{
    if (self.backgroundThread) {
        [self.backgroundThread cancel];
        [self performSelector:@selector(cancelNoop) onThread:self.backgroundThread withObject:nil
                waitUntilDone:NO];
    }
}

@end

@implementation StreamRunLoop (NSStreamDelegate)

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            NSLog(@"NSStreamEventNone");
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"NSStreamEventOpenCompleted");
            [self.openConnections addObject:aStream];
            if (self.openConnections.count == 2) {
                NSLog(@"connectionEstablished");
                self.connected = YES;
                [self.delegate connectionEstablished];
            }
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"NSStreamEventHasBytesAvailable");
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"NSStreamEventErrorOccurred");
            [self close];
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"NSStreamEventEndEncountered");
            [self close];
            break;
    }
}

@end


