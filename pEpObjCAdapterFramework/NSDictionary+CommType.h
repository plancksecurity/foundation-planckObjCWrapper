//
//  NSDictionary+Extension.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.09.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <PEPEngineTypes.h>

@interface NSDictionary (CommType)

/**
 If we interpret the self as a dictionary denoting a p≡p Identity,
 does the comm type denote a PGP user?
 */
@property (nonatomic, readonly) PEPCommType commType;

@end
