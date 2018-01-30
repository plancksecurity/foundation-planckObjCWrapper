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

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ownUserId;

@interface PEPTestUtils : NSObject

+ (PEPIdentity *)foreignPepIdentityWithAddress:(NSString *)address userName:(NSString *)username;

+ (PEPIdentity *)ownPepIdentityWithAddress:(NSString *)address userName:(NSString *)username;

+ (void)importBundledKey:(NSString *)item;

+ (NSString *)loadResourceByName:(NSString *)name;

+ (NSString *)loadStringFromFileName:(NSString *)fileName;

+ (NSDictionary *)unarchiveDictionary:(NSString *)fileName;

+ (PEPMessage * _Nonnull) mailFrom:(PEPIdentity * _Nullable) fromIdent
                           toIdent: (PEPIdentity * _Nullable) toIdent
                      shortMessage:(NSString *)shortMessage
                       longMessage: (NSString *)longMessage
                          outgoing:(BOOL) outgoing;

+ (void)deleteWorkFilesAfterBackingUpWithBackupName:(NSString * _Nullable)backup;

+ (void)restoreWorkFilesFromBackupNamed:(NSString *)backup;

+ (NSArray *)pEpWorkFiles;

@end

NS_ASSUME_NONNULL_END
