//
//  NSDictionary+Extension.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.09.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDictionary+Extension.h"

#import "PEPMessage.h"

@implementation NSDictionary (Extension)

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

- (BOOL)containsPGPCommType
{
    NSNumber *ctNum = self[kPepCommType];
    if (!ctNum) {
        return NO;
    }
    NSInteger val = ctNum.integerValue;

    return
    val == PEP_ct_OpenPGP_weak_unconfirmed ||
    val == PEP_ct_OpenPGP_unconfirmed ||
    val == PEP_ct_OpenPGP_weak ||
    val == PEP_ct_OpenPGP;
}

@end
