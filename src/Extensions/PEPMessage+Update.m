//
//  PEPMessage+Update.m
//  PEPObjCTypeUtils_iOS
//
//  Created by Dirk Zimmermann on 8/8/23.
//

#import "PEPMessage+Update.h"

@import PEPObjCTypes;

#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"

@implementation PEPMessage (Update)

- (void)updateIdentities
{
    NSMutableArray *allIdentities = [NSMutableArray arrayWithArray:@[self.from]];
    [allIdentities addObjectsFromArray:self.to];
    [allIdentities addObjectsFromArray:self.cc];
    [allIdentities addObjectsFromArray:self.bcc];

    PEPInternalSession *session = [PEPSessionProvider session];
    for (PEPIdentity *identity in allIdentities) {
        NSError *error = nil;
        BOOL success = NO;
        if (identity.isOwn) {
            success = [session mySelf:identity error:&error];
        } else {
            success = [session updateIdentity:identity error:&error];
        }
        NSAssert(success, @"ERROR updating identity (%@): %@", identity, error);
    }
}

@end
