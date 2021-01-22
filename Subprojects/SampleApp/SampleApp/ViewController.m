//
//  ViewController.m
//  SampleApp
//
//  Created by Andreas Buff on 22.01.21.
//

#import "ViewController.h"

#import "PEPObjCAdapter.h"
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
    testee.address = @"lkjasdf@kjahsdf.de";
    testee.userID = @"lskjdgf";
    [pEpSession mySelf:testee errorCallback:^(NSError * _Nonnull error) {
        NSLog(@"!");
    } successCallback:^(PEPIdentity * _Nonnull identity) {
        NSLog(@"success");
    }];
}

@end
