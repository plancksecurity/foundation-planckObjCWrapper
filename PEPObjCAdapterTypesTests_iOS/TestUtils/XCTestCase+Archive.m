//
//  XCTestCase+Archive.m
//  PEPObjCAdapterTypesTests_iOS
//
//  Created by Dirk Zimmermann on 16.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "XCTestCase+Archive.h"

@implementation XCTestCase (Archive)

+ (NSObject *)archiveAndUnarchiveObject:(NSObject *)object ofClass:(Class)ofClass
{
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object
                                         requiringSecureCoding:YES
                                                         error:&error];
    XCTAssertNotNil(data);

    NSObject *unarchivedObject = [NSKeyedUnarchiver unarchivedObjectOfClass:ofClass
                                                                   fromData:data
                                                                      error:&error];
    XCTAssertNotNil(unarchivedObject);

    return unarchivedObject;
}

@end
