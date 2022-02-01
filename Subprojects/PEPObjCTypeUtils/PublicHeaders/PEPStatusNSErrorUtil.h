//
//  NSErrorPEPStatusUtil.h
//  PEPObjCTypeUtils
//
//  Created by Andreas Buff on 15.11.21.
//

#import <Foundation/Foundation.h>

#import <PEPEngineTypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPStatusNSErrorUtil : NSObject

+ (NSError * _Nullable)errorWithPEPStatus:(PEPStatus)status;

/**
 If the given status indicates an error, tries to set the given error accordingly.
 @return YES if the given status indicates an error condition, NO otherwise.
 */
+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromPEPStatus:(PEPStatus)status;

@end

NS_ASSUME_NONNULL_END
