//
//  AppDelegate.m
//  TSNetwork
//
//  Created by zhaoxy on 13-6-13.
//  Copyright (c) 2013年 TSinghua. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //init database
    [TSDBConnection initializeDatabase];
    //init interface
    [self initializeControllers];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    //close database
    [TSDBConnection closeDatabase];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //open database
    [TSDBConnection getSharedDatabase];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    //clear image cache
    [[TSImageStore sharedStore] didReceiveMemoryWarning];
}

//init interface
-(void)initializeControllers {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = [[[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil] autorelease];
    [self.window makeKeyAndVisible];
}

@end
