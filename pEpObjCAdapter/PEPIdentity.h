//
//  PEPIdentity.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEPIdentity : NSObject

/**
 The network address of this identity
 */
@property (nonatomic, nonnull) NSString *address;

/**
 The (optional) user name.
 */
@property (nonatomic, nullable) NSString *userName;

/**
 Is this one of our own identities?
 */
@property BOOL isOwn;

- (id)initWithAddress:(NSString * _Nonnull)address userName:(NSString * _Nullable)userName;
- (id)initWithAddress:(NSString * _Nonnull)address;

@end
