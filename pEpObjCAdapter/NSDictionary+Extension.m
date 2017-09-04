//
//  NSDictionary+Extension.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.09.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

- (void)debugSaveToBasePath:(NSString * _Nonnull)basePath fileName:(NSString * _Nonnull)fileName
theExtension:(NSString * _Nonnull)theExtension
{
    NSDate *now = [NSDate date];
    NSString *nowDesc = [now description];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@_%@.%@",
                          basePath, fileName, nowDesc, theExtension];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    [self writeToURL:url atomically:YES];
}

@end
