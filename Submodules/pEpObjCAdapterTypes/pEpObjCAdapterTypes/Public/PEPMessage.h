//
//  PEPMessage.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 10.11.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#ifndef PEPMessage_h
#define PEPMessage_h

#import <Foundation/Foundation.h>

#ifdef FRAMEWORK_BUILD
#import <PEPObjCAdapterTypesFramework/PEPMsgDirection.h>
#else
#import "PEPMsgDirection.h"
#endif

@class PEPIdentity;
@class PEPAttachment;

NS_ASSUME_NONNULL_BEGIN

@interface PEPMessage : NSObject

@property (nonatomic, nullable) NSString *messageID;

@property (nonatomic, nullable) PEPIdentity *from;
@property (nonatomic, nullable) NSArray<PEPIdentity *> *to;
@property (nonatomic, nullable) NSArray<PEPIdentity *> *cc;
@property (nonatomic, nullable) NSArray<PEPIdentity *> *bcc;

@property (nonatomic, nullable) NSString *shortMessage;
@property (nonatomic, nullable) NSString *longMessage;
@property (nonatomic, nullable) NSString *longMessageFormatted;

@property (nonatomic, nullable) NSArray<PEPIdentity *> *replyTo;
@property (nonatomic, nullable) NSArray<NSString *> *inReplyTo;
@property (nonatomic, nullable) NSArray<NSString *> *references;

@property (nonatomic, nullable) NSDate *sentDate;
@property (nonatomic, nullable) NSDate *receivedDate;

@property (nonatomic, nullable) NSArray<PEPAttachment *> *attachments;

@property (nonatomic, nullable) NSArray<NSArray<NSString *> *> *optionalFields;
@property (nonatomic, nullable) NSArray<NSString *> *keywords;
@property (nonatomic, nullable) PEPIdentity *receivedBy;
@property (nonatomic) PEPMsgDirection direction;

/// A copy constructor.
- (instancetype)initWithMessage:(PEPMessage *)message;

@end

NS_ASSUME_NONNULL_END

#endif
