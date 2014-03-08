//
//  BMAppDelegate.m
//  BlackMagic
//
//  Created by Balázs Nemeth on 08/03/14.
//  Copyright (c) 2014 BlackBone. All rights reserved.
//

#import "BMAppDelegate.h"
#import "BMNetworkManager.h"
#import "SettingsHandler.h"
#import "BMPlayer.h"


@implementation BMAppDelegate

- (void) step:(NSString*)name{
    //test vár, hogy léphessen
    
        [[BMNetworkManager sharedManager] startRequestNextMove:name onCompletion:^(NSDictionary *result) {
            //test lép
            double delayInSeconds = 1.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                NSDictionary* input = @{@"action": @"playCard", @"resourceType": @"fire", @"cardIndex": @(1)};
                [[BMNetworkManager sharedManager] proceedPlayer:name withInput:input onCompletion:^(NSDictionary *result) {
                    NSLog(@"res: %@",result);
                    [self step:name];
                } failure:^(NSError *error) {
                    NSLog(@"error: %@",error);
                }];
            });
        } failure:^(NSError *error) {
            NSLog(@"error:%@",error);
        }];
//    });

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Override point for customization after application launch.
    // Override point for customization after application launch.
    // Override point for customization after application launch.
    [SettingsHandler sharedSettings].serverIPAddress = @"localhost";
    [SettingsHandler sharedSettings].serverPort=8123;
    
    
    //reset the server
   /* [[BMNetworkManager sharedManager] resetServerOnCompletion:^{
        //reg test A
        [[BMNetworkManager sharedManager] registerPlayer:@"testA" onCompletion:^(NSDictionary *result) {
            [self step:@"testA"];
        } failure:^(NSError *error) {
            NSLog(@"error:%@",error);
        }];
        
        //reg test B
        [[BMNetworkManager sharedManager] registerPlayer:@"testB" onCompletion:^(NSDictionary *result) {
            NSLog(@"res:%@",result);
            [self step:@"testB"];
        } failure:^(NSError *error) {
            NSLog(@"error:%@",error);
        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
    }];*/
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
