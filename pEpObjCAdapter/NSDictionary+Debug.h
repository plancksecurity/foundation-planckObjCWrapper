//
//  NSDictionary+Debug.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 07.06.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Debug)

/**
 Saves itself to the filesystem, under `NSApplicationSupportDirectory`.
 */
- (void)debugSaveToFilePath:(NSString * _Nonnull)filePath;

/**
 Treating this object as a pEp messages, find out the references and print them (for debugging).
 */
- (void)dumpReferences;

@end
