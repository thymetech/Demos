//
//  AppDelegate.h
//  MLWDemoTouchDB
//
//  Created by Mason Weems on 9/25/12.
//  Copyright (c) 2012 Mason Weems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>

@class RootTableViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RootTableViewController *rootTableViewController;
@property (nonatomic, retain) CouchDatabase *database;

@end
