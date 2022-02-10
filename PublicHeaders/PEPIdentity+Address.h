//
//  PEPIdentity+Address.h
//  pEpObjCAdapter
//
//  Created by Martín Brude on 9/2/22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEPIdentity.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity (Address)

- (nonnull instancetype)initWithUserId:(NSString *)userId
                              Protocol:(NSString *)protocol
                                    IP:(NSString *)ip
                                  port:(NSUInteger)port;
@end

NS_ASSUME_NONNULL_END
