//
//  PEPTypesTestUtil.h
//  PEPObjCAdapterTypesTests_iOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PEPIdentity, PEPAttachment, PEPLanguage, PEPMessage;
@class PEPMember, PEPGroup;

@interface PEPTypesTestUtil : NSObject

+ (PEPIdentity *)pEpIdentityWithAllFieldsFilled;
+ (PEPAttachment *)pEpAttachmentWithAllFieldsFilled;
+ (PEPLanguage *)pEpLanguageWithAllFieldsFilled;
+ (PEPMessage *)pEpMessageWithAllFieldsFilled;
+ (PEPMember *)pEpMemberWithAllFieldsFilled;
+ (PEPGroup *)pEpGroupWithAllFieldsFilled;

@end

NS_ASSUME_NONNULL_END
