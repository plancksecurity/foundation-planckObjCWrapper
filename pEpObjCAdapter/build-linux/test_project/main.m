//
//  main.m
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 06.08.21.
//

#import <Foundation/Foundation.h>

void test_dispatchToMainQueueNeverExecuted() {
    NSLog(@"test_dispatchToMainQueueNeverExecuted: Started");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"test_dispatchToMainQueueNeverExecuted: I am on background queue");
        // NSLog(@"test_dispatchToMainQueueNeverExecuted: Now sleep(1)");
        // sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"test_dispatchToMainQueueNeverExecuted: I am on main queue -  ASYNC");
        });
        if (![NSThread isMainThread]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"test_dispatchToMainQueueNeverExecuted: I am on main queue -  SYNC");
                NSLog(@"test_dispatchToMainQueueNeverExecuted: SUCCESS!");
            });
        }
    });

    if ([NSThread isMainThread]) {
        NSLog(@"test_dispatchToMainQueueNeverExecuted: [NSThread isMainThread] == true");
    } else {
        NSLog(@"test_dispatchToMainQueueNeverExecuted: PROBLEM. Should not be called");
    }

}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSLog(@"main");
           
        test_dispatchToMainQueueNeverExecuted();

        // NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        // NSLog(@"runLoop: %@", runLoop);
        // [runLoop run];
        NSLog(@"Before runloop");
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop run];
        // while (![NSThread currentThread].isCancelled) {
            // [runLoop runMode:NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]];
        // }
    }

    NSLog(@"bye!");

    return 0;
}
