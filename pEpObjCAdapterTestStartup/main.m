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

        dispatch_queue_t queue = dispatch_queue_create("queue", nil);

        dispatch_async(queue, ^{
            PEPSession *session = [PEPSession new];
            [session languageList:^(NSError * _Nonnull error) {
                NSLog(@"*** error: error");
            } successCallback:^(NSArray<PEPLanguage *> * _Nonnull languages) {
                NSLog(@"*** have %lu languages", (unsigned long) languages.count);
            }];
        });

        [NSRunLoop mainRunLoop];
    }
    return 0;
}
