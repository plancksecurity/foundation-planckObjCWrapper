//
//  main.m
//  pEpObjCAdapterTestStartup
//
//  Created by Dirk Zimmermann on 29.11.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPObjCAdapter.h"
#import "PEPSession.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Hello, World!");

        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_queue_create("queue", nil);

        dispatch_group_enter(group);

        dispatch_sync(queue, ^{
            PEPSession *session = [PEPSession new];
            [session languageList:^(NSError * _Nonnull error) {
                NSLog(@"*** error: error");
                dispatch_group_leave(group);
            } successCallback:^(NSArray<PEPLanguage *> * _Nonnull languages) {
                NSLog(@"*** have %lu languages", (unsigned long) languages.count);
                dispatch_group_leave(group);
            }];
        });

        dispatch_group_wait(group, durationForever);
    }
    return 0;
}
