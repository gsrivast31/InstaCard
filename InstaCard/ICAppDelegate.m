//
//  ICAppDelegate.m
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 16/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import "ICAppDelegate.h"
#import "ICCardViewController.h"
#import "ICUtils.h"
#import "ICCoreDataStack.h"
//#import "ICReminderController.h"

@interface ICAppDelegate ()

@end

@implementation ICAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ICCardViewController* cardViewController = [storyBoard instantiateViewControllerWithIdentifier:@"cardViewController"];
    [cardViewController setViewType:ICPersonal];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:cardViewController];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];

    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    [[ICCoreDataStack defaultStack] saveContext];
    //[ICReminderController sharedInstance];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Delete any expired date-based notifications
    //[[ICReminderController sharedInstance] deleteExpiredReminders];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[ICCoreDataStack defaultStack] saveContext];
}

#pragma mark - Reminder services
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //[[ICReminderController sharedInstance] didReceiveLocalNotification:notification];
}


@end
