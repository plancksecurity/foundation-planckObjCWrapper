//
//  PEPTypes.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 01.03.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Type definitions

typedef NSArray<NSString *> PEPStringList;

#pragma mark - Errors

/// Possible errors from adapter without involvement from the engine.
typedef NS_CLOSED_ENUM(NSInteger, PEPAdapterError) {
    /// Passwords are limited in size, and this error indicates a password that contains
    /// too many codepoints.
    PEPAdapterErrorPassphraseTooLong = 0
};
