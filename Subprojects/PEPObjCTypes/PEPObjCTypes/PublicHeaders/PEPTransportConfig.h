//
//  PEPTransportConfig.h
//
//  Created by Andreas Buff on 16.08.21.
//

#import <Foundation/Foundation.h>
#include <stddef.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPTransportConfig : NSObject
@property (nonatomic) Size size;
@property (nonatomic) UInt16 port;
@end

NS_ASSUME_NONNULL_END
