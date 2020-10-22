//
//  PEPMessage+Engine.h
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "message.h"

#import "PEPMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPMessage (Engine)

+ (PEPMessage * _Nullable)fromStruct:(message * _Nullable)msg;

- (message * _Nullable)toStruct;

/// Sets recipients with 0 member to nil
- (PEPMessage *)removeEmptyRecipients;

@end

NS_ASSUME_NONNULL_END
