//
//  ViewController.m
//  TEST_ObjCAdapterStaticLibUsage
//
//  Created by Andreas Buff on 01.12.20.
//

#import "ViewController.h"

#import "PEPSession.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    NSLog(@"Started up");
    PEPRating rating = [[PEPSession new] ratingFromString:@"reliable"];
    NSLog(@"PEPRating rating = [[PEPSession init] ratingFromString:@\"reliable\"];: %d", rating);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];



    // Update the view, if already loaded.
}


@end
