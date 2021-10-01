//
//  MyClass.h
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 06.08.21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyClass : NSObject 

@property (nonatomic) NSString *name;

- (instancetype)initWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
