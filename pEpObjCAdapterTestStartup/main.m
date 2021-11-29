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
        PEPSession *session = [PEPSession new];
        session = nil;
    }
    return 0;
}
