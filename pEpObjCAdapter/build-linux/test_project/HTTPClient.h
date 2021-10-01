//
//  HTTPClient.h
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 11.08.21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTTPClient : NSObject

- (NSData *)requestURLString:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
