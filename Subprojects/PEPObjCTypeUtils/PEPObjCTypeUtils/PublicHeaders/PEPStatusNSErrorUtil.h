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

//??
/**
 If the given status indicates an error, tries to set the given error accordingly.
 @return YES if the given status indicates an error condition, NO otherwise.
 */
+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromPEPStatus:(PEPStatus)status;

//!!!: this maybe privare after moving NSError<->PEP_STATUS from adapter to here
//// MARK: - NSString From PEP_STATUS
//
///// Could in theory return a fully localized version of the underlying error.
//NSString * _Nonnull localizedErrorStringFromPEPStatus(PEP_STATUS status);
//
//NSString * _Nonnull stringFromPEPStatus(PEP_STATUS status);

@end

NS_ASSUME_NONNULL_END
