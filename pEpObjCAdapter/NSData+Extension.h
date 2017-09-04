//
//  NSData+Extension.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.09.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#ifndef NSData_Extension_h
#define NSData_Extension_h

#import <Foundation/Foundation.h>

@interface NSData (Extension)

+ (NSData * _Nullable)debugReadDataFromFilePath:(NSString * _Nonnull)filePath;

+ (NSData * _Nullable)debugReadDataFromJsonFilePath:(NSString * _Nonnull)filePath;

- (void)debugSaveToBasePath:(NSString * _Nonnull)basePath fileName:(NSString * _Nonnull)fileName
               theExtension:(NSString * _Nonnull)theExtension;

- (void)debugSaveJsonToBasePath:(NSString * _Nonnull)basePath fileName:(NSString * _Nonnull)fileName
                   theExtension:(NSString * _Nonnull)theExtension;

@end


#endif /* NSData_Extension_h */
