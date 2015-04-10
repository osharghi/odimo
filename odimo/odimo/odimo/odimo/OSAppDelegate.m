//
//  OSAppDelegate.m
//  odimo
//
//  Created by omid sharghi on 4/24/14.
//  Copyright (c) 2014 TransPower. All rights reserved.
//

#import "OSAppDelegate.h"
#import <Parse/Parse.h>

@implementation OSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
//    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,320, 20)];
    view.backgroundColor=[UIColor colorWithRed:107/255.0f green:212/255.0f blue:231/255.0f alpha:1.0f];
    [self.window.rootViewController.view addSubview:view];
    
//    UIView *view2=[[UIView alloc] initWithFrame:CGRectMake(0, 524,320, 44)];
//    view2.backgroundColor=[UIColor colorWithRed:107/255.0f green:212/255.0f blue:231/255.0f alpha:1.0f];
//
//    [self.window.rootViewController.view addSubview:view2];
//    view2.hidden = YES;

    
    // Override point for customization after application launch.
    NSLog(@"ENTERED FINISH LAUNCHING");
    
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
    
    NSLog(@"ENTERED FOREGROUND");
    
    [UIView setAnimationsEnabled:YES];

    
    

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

//    self.returnFromBackground = @"YES";
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
//    self.returnFromBackground = @"YES";
    
}


@end
