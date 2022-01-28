//
//  PEPMessage+PEPConvert.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 25/1/22.
//
#import <Foundation/Foundation.h>

#import "message.h"
#import "PEPMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPMessage (Convert)

+ (PEPMessage * _Nullable)fromStruct:(message * _Nullable)msg;

- (message * _Nullable)toStruct;

+ (void)overWritePEPMessageObject:(PEPMessage *)pEpMessage
             withValuesFromStruct:(message * _Nonnull)message;

+ (void)removeEmptyRecipientsFromPEPMessage:(PEPMessage *)pEpMessage;

+ (PEPMessage *)pEpMessageWithEmptyRecipientsRemovedFromPEPMessage:(PEPMessage *)pEpMessage;

@end

NS_ASSUME_NONNULL_END
