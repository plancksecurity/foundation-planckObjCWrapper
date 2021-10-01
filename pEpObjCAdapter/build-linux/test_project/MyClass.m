//
//  MyClass.m
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 06.08.21.
//

#import "MyClass.h"

@implementation MyClass

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc object: %@", self.name);
}

@end
