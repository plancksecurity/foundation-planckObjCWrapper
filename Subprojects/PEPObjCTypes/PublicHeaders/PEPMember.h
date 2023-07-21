//
//  PEPMember.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PEPIdentity;

/// Wraps pEp_member (see group.h).
@interface PEPMember : NSObject

@property (nonatomic, readonly) PEPIdentity *identity;
@property (nonatomic) BOOL joined;

- (instancetype)initWithIdentity:(PEPIdentity *)identity joined:(BOOL)joined;

@end

NS_ASSUME_NONNULL_END
