//
//  main.m
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 06.08.21.
//

#import <Foundation/Foundation.h>

#import "Connector.h"
#import "HTTPClient.h"
#import <PEPSession.h>
#import <PEPMessage.h>
#import <PEPIdentity.h>

@class MyClass;

static MyClass *s_myClass;

#import "MyClass.h"

void test_arc_dealloc_once(NSString *baseName)
{
    NSLog(@"%@: test_arc_dealloc", baseName);
    NSArray *objs = @[[[MyClass alloc]
                       initWithName:[NSString stringWithFormat:@"%@_%@",
                                     baseName, @"1"]],
                      [[MyClass alloc]
                       initWithName:[NSString stringWithFormat:@"%@_%@",
                                     baseName, @"2"]],
                      [[MyClass alloc]
                       initWithName:[NSString stringWithFormat:@"%@_%@",
                                     baseName, @"3"]]];
    for (MyClass *obj in objs) {
        NSLog(@"%@: Have object: %@", baseName, obj.name);
    }

    // Finalize all objects
    NSLog(@"%@: Set objs to nil.", baseName);
    objs = nil;
}

void test_arc_dealloc(void)
{
    dispatch_group_t group = dispatch_group_create();

    dispatch_queue_t queue = dispatch_queue_create("1", NULL);

    for (NSNumber *num in @[@1, @2, @3, @4, @5, @6, @7, @8, @9]) {
        dispatch_group_async(group, queue, ^{
            test_arc_dealloc_once([NSString stringWithFormat:@"base_%@", num]);
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

void test_stream_connection(void)
{
    Connector *connector = [Connector new];
    [connector connectWithHostname:@"pep.security" port:80];
}

void request(void)
{
    HTTPClient *httpClient = [HTTPClient new];
    NSData *data = [httpClient requestURLString:@"https://www.pep.security/en/"];
    NSLog(@"Received %lu bytes", (unsigned long) data.length);
}

void test_using_objc_adapter() {
    NSLog(@"Starting: test_using_objc_adapter");
    NSString *ownUserID = @"s_ownUserID";
    NSString *ownAddress = @"me@ownAddress.com";
    NSString *ownUserName = @"My Name";

    PEPIdentity *me = [[PEPIdentity alloc] initWithAddress:ownAddress
                                                    userID:ownUserID
                                                  userName:ownUserName
                                                     isOwn:YES
                                               fingerPrint:nil
                                                  commType:PEPCommTypeUnknown
                                                  language:nil];
    PEPMessage *srcMsg = [PEPMessage new];
    srcMsg.from = me;
    srcMsg.to = @[me];
    srcMsg.direction = PEPMsgDirectionOutgoing;
    srcMsg.shortMessage = @"shortMessage";
    srcMsg.longMessage = @"longMessage";
    srcMsg.longMessageFormatted = @"longMessageFormatted";

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ // 0 == DISPATCH_QUEUE_PRORITY_DEFAULT
        NSLog(@"test_using_objc_adapter: call myself");
        PEPSession *session = [PEPSession new];
        [session mySelf:me errorCallback:^(NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
            dispatch_group_leave(group);
        } successCallback:^(PEPIdentity * _Nonnull identity) {
            PEPSession *session = [PEPSession new];
            [session encryptMessage:srcMsg extraKeys:nil errorCallback:^(NSError * _Nonnull error) {
                NSLog(@"Error encryptMessage: %@", error);
                dispatch_group_leave(group);
            } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
                NSLog(@"Encrypted message: %@", destMessage);
                NSLog(@"Original message: %@", srcMessage);
                dispatch_group_leave(group);
            }];    
        }];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"test_using_objc_adapter: Done");
    });
    NSLog(@"test_using_objc_adapter: waiting for adapter to return");
}

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
        s_myClass = [[MyClass alloc] initWithName:@"static"];
        s_myClass = nil;

        test_arc_dealloc();
        test_stream_connection();
        request();
        test_dispatchToMainQueueNeverExecuted();    
        test_using_objc_adapter();
        
        NSLog(@"Entering runloop");
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop run];
    }

    NSLog(@"bye!");

    return 0;
}
