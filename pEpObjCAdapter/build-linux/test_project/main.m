/// Simple test using pEpObjCAdapter on Linux & GNUstep.

#import <Foundation/Foundation.h>

#import <PEPSession.h>
#import <PEPMessage.h>
#import <PEPIdentity.h>

/// Calls myselve and encrypts a message.
void test_using_objc_adapter() {
    NSLog(@"test_using_objc_adapter: Starting");

    NSString *ownUserID = @"ownUserID";
    NSString *ownAddress = @"me@ownAddress.com";
    NSString *ownUserName = @"My Name";

    PEPIdentity *me = [[PEPIdentity alloc] initWithAddress:ownAddress
                                                    userID:ownUserID
                                                  userName:ownUserName
                                                     isOwn:YES
                                               fingerPrint:nil
                                                  commType:PEPCommTypeUnknown
                                                  language:nil];
    PEPMessage *srcMsg = [PEPMessage new];
    srcMsg.from = me;
    srcMsg.to = @[me];
    srcMsg.direction = PEPMsgDirectionOutgoing;
    srcMsg.shortMessage = @"shortMessage";
    srcMsg.longMessage = @"longMessage";
    srcMsg.longMessageFormatted = @"longMessageFormatted";

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ // 0 == DISPATCH_QUEUE_PRORITY_DEFAULT
        NSLog(@"test_using_objc_adapter: call myself");
        PEPSession *session = [PEPSession new];
        [session mySelf:me errorCallback:^(NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
            dispatch_group_leave(group);
        } successCallback:^(PEPIdentity * _Nonnull identity) {

            PEPSession *session = [PEPSession new];
            [session encryptMessage:srcMsg extraKeys:nil errorCallback:^(NSError * _Nonnull error) {
                NSLog(@"test_using_objc_adapter: Error encryptMessage: %@", error);
                dispatch_group_leave(group);
            } successCallback:^(PEPMessage * _Nonnull srcMessage, PEPMessage * _Nonnull destMessage) {
                NSLog(@"test_using_objc_adapter: Encrypted message: %@", destMessage);
                NSLog(@"test_using_objc_adapter: Original message: %@", srcMessage);
                dispatch_group_leave(group);
            }];   

        }];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"test_using_objc_adapter: Done");
    });
    NSLog(@"test_using_objc_adapter: waiting for adapter to return");
}   

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSLog(@"main");
  
        test_using_objc_adapter();
        
        NSLog(@"Entering runloop");
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop run];
    }

    NSLog(@"bye!");

    return 0;
}
