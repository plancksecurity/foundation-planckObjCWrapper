//
//  PEPGroup.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PEPIdentity;
@class PEPMember;

@interface PEPGroup : NSObject

@property (nonatomic, readonly) PEPIdentity *identity;
@property (nonatomic, readonly) PEPIdentity *manager;
@property (nonatomic, readonly) NSArray<PEPMember *> *members;
@property (nonatomic) BOOL active;

- (instancetype)initWithIdentity:(PEPIdentity *)identity
                         manager:(PEPIdentity *)manager
                         members:(NSArray<PEPMember *> *)members
                          active:(BOOL)active;

@end

NS_ASSUME_NONNULL_END
