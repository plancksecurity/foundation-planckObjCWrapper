//
//  NSDictionary_NSDictionary_Extension.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.09.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "pEpEngine.h"

@interface NSDictionary (Extension)

/**
 If we interpret the self as a dictionary denoting a p≡p Identity,
 does the comm type denote a PGP user?
 */
@property (nonatomic, readonly) PEP_comm_type commType;

/**
 If we interpret the self as a dictionary denoting a p≡p Identity,
 does the comm type denote a PGP user?
 */
@property (nonatomic, readonly) BOOL containsPGPCommType;

/**
 Saves itself to the filesystem, under `NSApplicationSupportDirectory`.
 */
- (void)debugSaveToFilePath:(NSString * _Nonnull)filePath;

@end
