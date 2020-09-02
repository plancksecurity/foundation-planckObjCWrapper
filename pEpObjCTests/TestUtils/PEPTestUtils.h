//
//  PEPTestUtils.h
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 17.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PEPIdentity;
@class PEPInternalSession;
@class PEPMessage;
@class PEPSession;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ownUserId;

/**
 Timeout for internal sync operations.
 */
extern const NSInteger PEPTestInternalSyncTimeout;

@interface PEPTestUtils : NSObject

+ (PEPIdentity *)foreignPepIdentityWithAddress:(NSString *)address userName:(NSString *)username;

+ (PEPIdentity *)ownPepIdentityWithAddress:(NSString *)address userName:(NSString *)username;

+ (BOOL)importBundledKey:(NSString *)item session:(PEPInternalSession *)session;

+ (NSString *)loadResourceByName:(NSString *)name;

+ (NSString *)loadStringFromFileName:(NSString *)fileName;

+ (NSDictionary *)unarchiveDictionary:(NSString *)fileName;

+ (void)migrateUnarchivedMessageDictionary:(NSMutableDictionary *)message;

+ (PEPMessage * _Nonnull) mailFrom:(PEPIdentity * _Nullable) fromIdent
                           toIdent: (PEPIdentity * _Nullable) toIdent
                      shortMessage:(NSString *)shortMessage
                       longMessage: (NSString *)longMessage
                          outgoing:(BOOL) outgoing;

+ (void)cleanUp;

@end

NS_ASSUME_NONNULL_END
