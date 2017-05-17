//
//  PEPQueue.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 15.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEPQueue : NSObject

- (void)enqueue:(id)object;

- (id)dequeue;

- (void)kill;

- (NSUInteger)count;

@end
