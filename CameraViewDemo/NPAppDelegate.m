//
//  NPAppDelegate.m
//  CameraViewDemo
//
//  Created by Nebojsa Petrovic on 4/27/13.
//  Copyright (c) 2013 Nebojsa Petrovic. All rights reserved.
//

#import "NPAppDelegate.h"

#import "NPViewController.h"

@implementation NPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [application setStatusBarHidden:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [NPViewController new];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
