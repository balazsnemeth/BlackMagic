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
@import AVFoundation;


@implementation BMAppDelegate{
    AVAudioPlayer * backgroundMusicPlayer;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Override point for customization after application launch.
    
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
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SettingsHandler sharedSettings].autoPlayByAI = TRUE;
//    [SettingsHandler sharedSettings].serverIPAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipAddress"];
        [SettingsHandler sharedSettings].serverIPAddress = @"192.168.1.104:8123";
//    NSString* port = [[NSUserDefaults standardUserDefaults] objectForKey:@"port"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Connection:%@",[SettingsHandler sharedSettings].serverIPAddress);
    
    NSError *error;
    
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"backgroung" withExtension:@"mp3"];
    backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    backgroundMusicPlayer.numberOfLoops = -1;
    [backgroundMusicPlayer prepareToPlay];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [backgroundMusicPlayer play];
    });

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
