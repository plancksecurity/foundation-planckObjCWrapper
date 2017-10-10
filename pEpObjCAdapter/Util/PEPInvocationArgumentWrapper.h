//
//  PEPInvocationArgumentWrapper.h
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 10.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

//BUFF: obsolete?
typedef NS_ENUM(NSUInteger, PEPInvocationArgumentWrapperType) {
    typeInteger = 1,
    typeObject
};

@interface PEPInvocationArgumentWrapper : NSObject

@property (readonly) id value;
@property (readonly) PEPInvocationArgumentWrapperType type;

+ (instancetype)instanceWithInteger:(NSInteger)value;
+ (instancetype)instanceWithObject:(id)value;

@end
