//
//  XCTestCase+Archive.h
//  PEPObjCAdapterTypesTests_iOS
//
//  Created by Dirk Zimmermann on 16.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (Archive)

- (NSObject *)archiveAndUnarchiveObject:(NSObject *)object ofClass:(Class)ofClass;

@end

NS_ASSUME_NONNULL_END
