//
//  main.m
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 06.08.21.
//

#import <Foundation/Foundation.h>

#import "Connector.h"
#import "HTTPClient.h"
// #import <PEPSession.h>
// #import <PEPMessage.h>
// #import <PEPIdentity.h>

@class MyClass;

static MyClass *s_myClass;



#import "MyClass.h"

// void test_using_objc_adapter() {
//     NSString *ownUserID = @"s_ownUserID";
//     NSString *ownAddress = @"me@ownAddress.com";
//     NSString *ownUserName = @"My Name";

//     PEPMessage *srcMsg = [PEPMessage new];
//     srcMsg.from = me;
//     srcMsg.to = [me];

//     PEPIdentity *me = [[PEPIdentity alloc] initWithAddress:ownUserID
//                                                     userID:ownUserID
//                                                   userName:ownUserName
//                                                      isOwn:YES
//                                                fingerPrint:nil
//                                                   commType:NULL
//                                                   language:nil];
//     PEPSession *session = [PEPSession new];
//     [session mySelf:me errorCallback:^(NSError * _Nonnull error) {
//         NSLog(@"Error: %@", error);
//     } successCallback:^(PEPIdentity * _Nonnull identity) {
//         [session encryptMessage:srcMsg extraKeys:(PEPStringList * _Nullable) errorCallback:^(NSError * _Nonnull error) {
//             NSLog(@"Error: %@", error);
//         } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
//             NSLog(@"Success!");
//             NSLog(@"Encrypted message: %@", destMessage);
//             NSLog(@"Original message: %@", srcMessage);
//         }]]
//     }];
// }

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

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSLog(@"main");

        s_myClass = [[MyClass alloc] initWithName:@"static"];
        s_myClass = nil;

        test_arc_dealloc();
        test_stream_connection();
        request();
        // test_using_objc_adapter()
    }

    return 0;
}
