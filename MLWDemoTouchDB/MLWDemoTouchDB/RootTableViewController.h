//
//  RootTableViewController.h
//  MLWDemoTouchDB
//
//  Created by Mason Weems on 9/26/12.
//  Copyright (c) 2012 Mason Weems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchCocoa/CouchUITableSource.h>

@class CouchDatabase, CouchPersistentReplication;
@interface RootTableViewController : UIViewController <CouchUITableDelegate, UITextFieldDelegate>

@property (nonatomic, retain) CouchPersistentReplication* pull;
@property (nonatomic, retain) CouchPersistentReplication* push;
@property (nonatomic)     BOOL showingSyncButton;

@property (nonatomic, retain) IBOutlet  CouchUITableSource* dataSource;
@property (nonatomic, retain) IBOutlet  UITableView *tableView;
@property (nonatomic, retain)           UIProgressView *pvSync;
@property (nonatomic, retain) IBOutlet  UITextField *tfAddItem;
@property (nonatomic, retain) IBOutlet  UIImageView *ivAddItem;

- (IBAction) configureSync:(id)sender;
- (IBAction) deleteCheckedItems:(id)sender;

@end
