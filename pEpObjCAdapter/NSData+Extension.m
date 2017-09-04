//
//  NSData+Extension.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.09.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSData+Extension.h"

@implementation NSData (Extension)

+ (NSData * _Nullable)debugReadDataFromFilePath:(NSString * _Nonnull)filePath
{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSData *theData = [NSData dataWithContentsOfURL:url];
    return theData;
}

+ (NSData * _Nullable)debugReadDataFromJsonFilePath:(NSString * _Nonnull)filePath
{
    NSData *theData = [self debugReadDataFromFilePath:filePath];
    if (theData) {
        NSError *error;
        return [NSJSONSerialization JSONObjectWithData:theData options:0 error:&error];
    }
    return nil;
}

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

- (void)debugSaveJsonToBasePath:(NSString * _Nonnull)basePath fileName:(NSString * _Nonnull)fileName
                   theExtension:(NSString * _Nonnull)theExtension
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:self
                        options:NSJSONWritingPrettyPrinted error:&error];
    [jsonData debugSaveJsonToBasePath:basePath fileName:fileName theExtension:theExtension];
}

@end
