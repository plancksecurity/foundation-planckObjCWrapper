//
//  HTTPClient.m
//  CrossPlatformObjC
//
//  Created by Dirk Zimmermann on 11.08.21.
//

#import "HTTPClient.h"

@implementation HTTPClient

- (NSData *)requestURLString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];

    if (data != nil) {
        return data;
    }  else {
        if (error) {
            NSLog(@"*** ERROR: %@", error);
        } else {
            NSLog(@"*** ERROR: No data received");
        }
        return nil;
    }
}

@end
