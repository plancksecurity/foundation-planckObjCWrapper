//
//  NSError+PEPStatus.m
//  PEPObjCTypeUtils
//
//  Created by David Alarcon on 6/9/21.
//

#import "NSError+PEPStatus.h"

@implementation NSError (PEPStatus)

/// Could in theory return a fully localized version of the underlying error.
NSString * _Nonnull localizedErrorStringFromPEPStatus(PEP_STATUS status) {
    return stringFromPEPStatus(status);
}

NSString * _Nonnull stringFromPEPStatus(PEP_STATUS status) {
    const char *pstrStatus = pEp_status_to_string(status);
    return [NSString stringWithUTF8String:pstrStatus];
}

@end
