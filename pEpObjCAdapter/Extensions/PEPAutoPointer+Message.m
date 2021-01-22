//
//  PEPAutoPointer+Message.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 02.12.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPAutoPointer+Message.h"

@implementation PEPAutoPointer (Message)

+ (instancetype)autoPointerWithMessage:(message *)message
{
    return [[self alloc] initWithMessage:message];
}

- (instancetype)initWithMessage:(message *)message
{
    return [self initWithPointer:message freeFn:(void (*)(void *)) free_message];
}

@end
