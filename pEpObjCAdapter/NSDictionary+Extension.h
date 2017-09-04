//
//  NSDictionary_NSDictionary_Extension.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.09.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extension)

- (void)debugSaveToBasePath:(NSString * _Nonnull)basePath fileName:(NSString * _Nonnull)fileName
               theExtension:(NSString * _Nonnull)theExtension;

@end
