//
//  ViewController.m
//  TEST_ObjCAdapterStaticLibUsage
//
//  Created by Andreas Buff on 01.12.20.
//

#import "ViewController.h"

#import "PEPSession.h"
#import "PEPIdentity.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PEPSession *pEpSession = [[PEPSession alloc] init];

    // Do any additional setup after loading the view.
    NSLog(@"Started up");
    PEPRating rating = [pEpSession ratingFromString:@"reliable"];
    NSLog(@"PEPRating rating = [pEpSession ratingFromString:@\"reliable\"];: %d", rating);

    PEPIdentity * testee = [[PEPIdentity alloc] init];
    testee.address = @"dummy@data.de";
    testee.userID = @"DUMMY_ID";
    [pEpSession mySelf:testee errorCallback:^(NSError * _Nonnull error) {
        NSLog(@"!");
        assert(false);
    } successCallback:^(PEPIdentity * _Nonnull identity) {
        NSLog(@"success");
    }];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];



    // Update the view, if already loaded.
}


@end
