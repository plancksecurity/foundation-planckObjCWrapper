//
//  PEPCSVScanner.h
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 03.05.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEPCSVScanner : NSObject

@property (nonatomic, readonly, nonnull) NSString *string;

- (instancetype _Nonnull )initWithString:(NSString * _Nonnull)string;
- (NSString * _Nullable)nextString;

@end
