//
//  NSDictionary+Debug.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 07.06.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "NSDictionary+Debug.h"

#import <PEPObjCAdapterFramework/PEPConstants.h>

#import "PEPMessageUtil.h"

@implementation NSDictionary (Debug)

- (void)debugSaveToFilePath:(NSString * _Nonnull)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *parentPath = [[fileManager
                          URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask]
                         firstObject];

    NSDate *now = [NSDate date];
    NSString *nowDesc = [now description];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@",
                          filePath, nowDesc, @"plist"];

    NSURL *writeURL = [NSURL fileURLWithPath:fileName relativeToURL:parentPath];
    NSLog(@"debugSaveToFilePath: writing %@", writeURL);
    [self writeToURL:writeURL atomically:YES];
}

- (void)dumpReferences
{
    NSString *messageID = [self valueForKey:kPepID];
    if (messageID == nil) {
        messageID = @"unknown";
    }
    NSArray *references = [self valueForKey:kPepReferences];
    if (references.count > 0) {
        for (NSString *ref in references) {
            NSLog(@"messageID %@ -> ref %@\n", messageID, ref);
        }
    } else {
        NSLog(@"messageID %@ -> no refs\n", messageID);
    }
}

@end
