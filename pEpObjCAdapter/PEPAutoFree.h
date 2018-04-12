//
//  PEPAutoFree.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 11.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Enable use of ARC (or manual cocoa memory management) for malloc-created pointers.
 */
@interface PEPAutoFree : NSObject

- (void **)pointerPointer;

@end
