//
//  PEPQueue.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 15.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEPQueue : NSMutableArray

- (void)enqueue:(id)object;
- (id)dequeue;

@end
