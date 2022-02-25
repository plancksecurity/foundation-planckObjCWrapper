//
//  main.m
//  ObjCHelloWorld
//
//  Created by Andreas Buff on 20.01.22.
//

#import <Foundation/Foundation.h>

#import "PEPObjCHelloWorldPrinter.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        PEPObjCHelloWorldPrinter *printer = [PEPObjCHelloWorldPrinter new];
        [printer print];
    }
    return 0;
}
