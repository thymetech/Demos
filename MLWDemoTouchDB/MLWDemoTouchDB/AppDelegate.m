//
//  AppDelegate.m
//  MLWDemoTouchDB
//
//  Created by Mason Weems on 9/25/12.
//  Copyright (c) 2012 Mason Weems. All rights reserved.
//

#import "AppDelegate.h"
#import "CouchManager.h"
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>
#import "RootTableViewController.h"

#define CLASS_DEBUG 1
#import "DDGMacros.h"

// The default remote database URL to sync with, if the user hasn't set a different one as a pref.
//#define kDefaultSyncDbURL @"http://couchbase.iriscouch.com/grocery-sync"

@implementation AppDelegate

- (RootTableViewController *) rootTableViewController;
{
    if (!_rootTableViewController) {
        self.rootTableViewController = [[RootTableViewController alloc] initWithNibName:@"RootTableViewController" bundle:nil];
    }
    return _rootTableViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DDGTrace();
    
    [self configureManagers];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    
//    UIViewController *aViewController = [[UIViewController alloc] init];
//    aViewController.view.backgroundColor = [UIColor purpleColor];
//    [aViewController.view addSubview:self.rootTableViewController.view];
    
    UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:self.rootTableViewController];
    
    self.window.rootViewController = aNavigationController;
    self.window.rootViewController.view.backgroundColor = [UIColor redColor];
    
    [self.window makeKeyAndVisible];
    
//    gCouchLogLevel = 1;
//    CouchTouchDBServer* server;
//#ifdef USE_REMOTE_SERVER
//    server = [[CouchTouchDBServer alloc] initWithURL: [NSURL URLWithString: USE_REMOTE_SERVER]];
//#else
//    server = [[CouchTouchDBServer alloc] init];
//#endif
//    if (server.error) {
//        [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"App Could not create server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//    }
//    self.database = [server databaseNamed: @"grocery-sync"];
//    NSError* error;
//    if (![self.database ensureCreated: &error]) {
//        [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"App Could not create local database" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
//        return YES;
//    }

    return YES;
}

- (void) configureServer {
#ifdef kDefaultSyncDbURL
    DDGTrace();
    // Register the default value of the pref for the remote database URL to sync with:
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appdefaults = [NSDictionary dictionaryWithObject:kDefaultSyncDbURL
                                                            forKey:@"syncpoint"];
    [defaults registerDefaults:appdefaults];
    [defaults synchronize];
#endif
}

- (void) configureManagers {
    DDGTrace();
    
    NSError *error = nil;
    if (![[CouchManager sharedCouchManager] startCouchbaseMobileServer:&error]) {
        DDGLog(@"ERROR: %@", [error localizedDescription]);
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    DDGTrace();
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDGTrace();
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDGTrace();
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DDGTrace();
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDGTrace();
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
