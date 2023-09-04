//
//  XCTestCase+PEPSession.h
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 09.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (PEPSession)

#pragma mark - Normal session to async

- (PEPRating)ratingForIdentity:(PEPIdentity *)identity;

- (PEPIdentity * _Nullable)mySelf:(PEPIdentity *)identity
                            error:(NSError * _Nullable * _Nullable)error;

- (NSArray<NSString *> * _Nullable)trustwordsForFingerprint:(NSString *)fingerprint
                                                 languageID:(NSString *)languageID
                                                  shortened:(BOOL)shortened
                                                      error:(NSError * _Nullable * _Nullable)error;

- (PEPIdentity * _Nullable)updateIdentity:(PEPIdentity *)identity
                                    error:(NSError * _Nullable * _Nullable)error;

- (NSNumber * _Nullable)outgoingRatingForMessage:(PEPMessage *)theMessage
                                           error:(NSError * _Nullable * _Nullable)error;

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage *)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                               encFormat:(PEPEncFormat)encFormat
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

- (PEPMessage * _Nullable)encryptMessage:(PEPMessage *)message
                               extraKeys:(PEPStringList * _Nullable)extraKeys
                                  status:(PEPStatus * _Nullable)status
                                   error:(NSError * _Nullable * _Nullable)error;

- (BOOL)trustPersonalKey:(PEPIdentity *)identity
                   error:(NSError * _Nullable * _Nullable)error;

- (BOOL)keyResetTrust:(PEPIdentity *)identity
                error:(NSError * _Nullable * _Nullable)error;

- (BOOL)keyMistrusted:(PEPIdentity *)identity error:(NSError * _Nullable * _Nullable)error;

- (BOOL)enableSyncForIdentity:(PEPIdentity *)identity
                        error:(NSError * _Nullable * _Nullable)error;

- (BOOL)disableSyncForIdentity:(PEPIdentity *)identity
                         error:(NSError * _Nullable * _Nullable)error;

- (NSString * _Nullable)getLogWithError:(NSError * _Nullable * _Nullable)error;

- (NSString * _Nullable)getTrustwordsIdentity1:(PEPIdentity *)identity1
                                     identity2:(PEPIdentity *)identity2
                                      language:(NSString * _Nullable)language
                                          full:(BOOL)full
                                         error:(NSError * _Nullable * _Nullable)error;

- (NSNumber * _Nullable)isPEPUser:(PEPIdentity *)identity
                            error:(NSError * _Nullable * _Nullable)error;

- (BOOL)trustOwnKeyIdentity:(PEPIdentity *)identity
                      error:(NSError * _Nullable * _Nullable)error;

- (BOOL)keyReset:(PEPIdentity *)identity
     fingerprint:(NSString * _Nullable)fingerprint
           error:(NSError * _Nullable * _Nullable)error;

- (BOOL)syncReinit:(NSError * _Nullable *)error;

- (NSArray<NSString *> * _Nullable)importExtraKey:(NSString *)extraKey
                                            error:(NSError * _Nullable *)error;

#pragma mark - Signing

- (NSString *)signText:(NSString *)stringToSign
                 error:(NSError **)error;

- (BOOL)verifyText:(NSString *)textToVerify
         signature:(NSString *)signature
          verified:(BOOL *)verified
             error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
