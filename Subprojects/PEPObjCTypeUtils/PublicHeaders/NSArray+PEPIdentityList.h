//
//  NSArray+PEPIdentityList.h.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 28/1/22.
//

#import <Foundation/Foundation.h>
#import "bloblist.h"
#import "stringpair.h"
#import "stringlist.h"
#import "PEPIdentity+Convert.h"
#import "PEPMessage+Convert.h"

@class PEPMessage;
@class PEPIdentity;
@class PEPAttachment;

NS_ASSUME_NONNULL_BEGIN

// NSArray<PEPIdentity> <-> identity_list

@interface NSArray (PEPIdentityList)

+ (NSArray<PEPIdentity*> *)fromIdentityList:(identity_list *)identityList;

- (identity_list * _Nullable)toIdentityList;

@end

NS_ASSUME_NONNULL_END
