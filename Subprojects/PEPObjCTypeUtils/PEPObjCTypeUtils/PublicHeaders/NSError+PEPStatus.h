//
//  NSError+PEPStatus.h
//  PEPObjCTypeUtils
//
//  Created by David Alarcon on 6/9/21.
//

#import <Foundation/Foundation.h>

#import <status_to_string.h>

NS_ASSUME_NONNULL_BEGIN

/// Could in theory return a fully localized version of the underlying error.
NSString * _Nonnull localizedErrorStringFromPEPStatus(PEP_STATUS status);
NSString * _Nonnull stringFromPEPStatus(PEP_STATUS status);

@interface NSError (PEPStatus)

@end

NS_ASSUME_NONNULL_END
