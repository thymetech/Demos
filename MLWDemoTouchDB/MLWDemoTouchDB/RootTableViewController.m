//
//  RootTableViewController.m
//  MLWDemoTouchDB
//
//  Created by Mason Weems on 9/26/12.
//  Copyright (c) 2012 Mason Weems. All rights reserved.
//

#import "CouchManager.h"
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchDesignDocument_Embedded.h>
#import "RootTableViewController.h"
#import "ConfigViewController.h"

#define CLASS_DEBUG 1
#import "DDGMacros.h"

@interface RootTableViewController ()

@end

@implementation RootTableViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (CouchDatabase *) database;
{
    return [CouchManager sharedCouchManager].database;
}

- (CouchUITableSource *) dataSource;
{
    if (!_dataSource) {
        DDGLog(@"Create dataSource");
        self.dataSource = [[CouchUITableSource alloc] init];
    }
    return _dataSource;
}

- (UITextField *) tfAddItem;
{
    if (!_tfAddItem) {
        DDGLog(@"Create text field");
        self.tfAddItem = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50.0f)];
        self.tfAddItem.delegate = self;
    }

    return _tfAddItem;
}

- (UIImageView *) ivAddItem;
{
    if (!_ivAddItem) {
        DDGLog(@"Create image view");
        self.ivAddItem = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50.0f)];
    }
    
    return _ivAddItem;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.ivAddItem];
    [self.view addSubview:self.tfAddItem];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc] initWithTitle: @"Clean"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target: self
                                                                    action: @selector(deleteCheckedItems:)];
    self.navigationItem.leftBarButtonItem = deleteButton;
    
    [self showSyncButton];

    [self configureDatabase];

    // Create a query sorted by descending date, i.e. newest items first:
    NSAssert(self.database!=nil, @"Not hooked up to database yet");
    CouchLiveQuery* query = [[[self.database designDocumentWithName: @"grocery"]
                              queryViewNamed: @"byDate"] asLiveQuery];
    query.descending = YES;
    
    
    self.dataSource.query = query;
    self.dataSource.labelProperty = @"text";    // Document property to display in the cell label
    
    // REF: https://groups.google.com/forum/#!msg/mobile-couchbase/ioyK8DZV0NM/aIoUBGd7dFAJ
//    self.dataSource.tableView = self.tableView;
//    self.tableView.dataSource = self.dataSource;
    
    [self updateSyncURL];

}


- (void) viewWillDisappear:(BOOL)animated {
    DDGTrace();
    [self forgetSync];
    [super viewWillDisappear:animated];
}


- (void)viewWillAppear:(BOOL)animated {
    DDGTrace();
    [super viewWillAppear: animated];
    // Check for changes after returning from the sync config view:
    [self updateSyncURL];
}


- (void) configureDatabase;
{
    
    DDGLog(@"FUTURE: Use database passed in, but for now just use shared database");
    
    // Create a 'view' containing list items sorted by date:
    CouchDesignDocument* design = [self.database designDocumentWithName: @"grocery"];
    [design defineViewNamed: @"byDate" mapBlock: MAPBLOCK({
        id date = [doc objectForKey: @"created_at"];
        if (date) emit(date, doc);
    }) version: @"1.0"];
    
    // and a validation function requiring parseable dates:
    design.validationBlock = VALIDATIONBLOCK({
        if (newRevision.deleted)
            return YES;
        id date = [newRevision.properties objectForKey: @"created_at"];
        if (date && ! [RESTBody dateWithJSONObject: date]) {
            context.errorMessage = [@"invalid date " stringByAppendingString: date];
            return NO;
        }
        return YES;
    });
    
}


- (void)didReceiveMemoryWarning
{
    DDGTrace();
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    NSInteger numberOfRows = [self.dataSource.rows count];
//    DDGLog(@"numberOfRows=%i", numberOfRows);
//    return numberOfRows;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)showErrorAlert: (NSString*)message forOperation: (RESTOperation*)op {
    DDGLog(@"%@: op=%@, error=%@", message, op, op.error);
    [[[UIAlertView alloc] initWithTitle:@"ERROR" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark -
#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CouchQueryRow *row = [self.dataSource rowAtIndex:indexPath.row];
    CouchDocument *doc = [row document];
    
    // Toggle the document's 'checked' property:
    NSMutableDictionary *docContent = [doc.properties mutableCopy];
    BOOL wasChecked = [[docContent valueForKey:@"check"] boolValue];
    [docContent setObject:[NSNumber numberWithBool:!wasChecked] forKey:@"check"];
    
    // Save changes, asynchronously:
    RESTOperation* op = [doc putProperties:docContent];
    [op onCompletion: ^{
        if (op.error)
            [self showErrorAlert: @"Failed to update item" forOperation: op];
        // Re-run the query:
		[self.dataSource.query start];
    }];
    [op start];
}


#pragma mark - Editing:


- (NSArray*)checkedDocuments {
    // If there were a whole lot of documents, this would be more efficient with a custom query.
    NSMutableArray* checked = [NSMutableArray array];
    for (CouchQueryRow* row in self.dataSource.rows) {
        CouchDocument* doc = row.document;
        if ([[doc.properties valueForKey:@"check"] boolValue])
            [checked addObject: doc];
    }
    return checked;
}

#define TAG_ALERT_REMOVE_COMPLETED_ITEMS 1001
- (IBAction)deleteCheckedItems:(id)sender {
    NSUInteger numChecked = self.checkedDocuments.count;
    if (numChecked == 0)
        return;
    NSString* message = [NSString stringWithFormat: @"Are you sure you want to remove the %u"
                         " checked-off item%@?",
                         numChecked, (numChecked==1 ? @"" : @"s")];
    NSString *title = NSLocalizedString(@"Remove Completed Items?", @"");
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: title
                                                    message: message
                                                   delegate: self
                                          cancelButtonTitle: @"Cancel"
                                          otherButtonTitles: @"Remove", nil];
    alert.tag = TAG_ALERT_REMOVE_COMPLETED_ITEMS;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    DDGLog(@"alertView.tag=%i; buttonIndex=%i", alertView.tag, buttonIndex);
    switch (alertView.tag) {
        case TAG_ALERT_REMOVE_COMPLETED_ITEMS:
            DDGLog(@"Tag matches TAG_ALERT_REMOVE_COMPLETED_ITEMS=%i", TAG_ALERT_REMOVE_COMPLETED_ITEMS);
            [self.dataSource deleteDocuments: self.checkedDocuments];
            break;
            
        default:
            break;
    }
}

#pragma mark - UITextField delegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
    [self.ivAddItem setImage:[UIImage imageNamed:@"textfield___inactive.png"]];
    
	return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.ivAddItem setImage:[UIImage imageNamed:@"textfield___active.png"]];
}


-(void)textFieldDidEndEditing:(UITextField *)textField {
    // Get the name of the item from the text field:
	NSString *text = self.tfAddItem.text;
    if (text.length == 0) {
        return;
    }
    [self.tfAddItem setText:nil];
    
    // Create the new document's properties:
	NSDictionary *inDocument = [NSDictionary dictionaryWithObjectsAndKeys:text, @"text",
                                [NSNumber numberWithBool:NO], @"check",
                                [RESTBody JSONObjectWithDate: [NSDate date]], @"created_at",
                                nil];
    
    // Save the document, asynchronously:
    CouchDocument* doc = [self.database untitledDocument];
    RESTOperation* op = [doc putProperties:inDocument];
    [op onCompletion: ^{
        if (op.error)
            [self showErrorAlert: @"Couldn't save the new item" forOperation: op];
        // Re-run the query:
		[self.dataSource.query start];
	}];
    [op start];
}


#pragma mark -
#pragma mark - SYNC:


- (IBAction)configureSync:(id)sender {
    UINavigationController* navController = (UINavigationController*)self.parentViewController;
    ConfigViewController* controller = [[ConfigViewController alloc] init];
    [navController pushViewController: controller animated: YES];
}


- (void)updateSyncURL {
    DDGTrace();
    if (!self.database)
        return;
    
    NSURL* newRemoteURL = nil;
    NSString *syncpoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"syncpoint"];
    DDGLog(@"syncpoint='%@'", syncpoint);
    
    if (syncpoint.length > 0)
        newRemoteURL = [NSURL URLWithString:syncpoint];
    
    [self forgetSync];
    
    NSArray* repls = [self.database replicateWithURL: newRemoteURL exclusively: YES];
    self.pull = [repls objectAtIndex: 0];
    self.push = [repls objectAtIndex: 1];
    [self.pull addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
    [self.push addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
}


- (void) forgetSync {
    [self.pull removeObserver: self forKeyPath: @"completed"];
    self.pull = nil;
    [self.push removeObserver: self forKeyPath: @"completed"];
    self.push = nil;
}


- (void)showSyncButton {
    if (!self.showingSyncButton) {
        self.showingSyncButton = YES;
        UIBarButtonItem* syncButton =
        [[UIBarButtonItem alloc] initWithTitle: @"Configure"
                                         style:UIBarButtonItemStylePlain
                                        target: self
                                        action: @selector(configureSync:)];
        self.navigationItem.rightBarButtonItem = syncButton;
    }
}

- (UIProgressView *) pvSync
{
    if (!_pvSync) {
        DDGLog(@"Create progress view");
        self.pvSync = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        CGRect frame = self.pvSync.frame;
        frame.size.width = self.view.frame.size.width / 4.0f;
        self.pvSync.frame = frame;
    }
    return _pvSync;
}

- (void)showSyncStatus {
    if (self.showingSyncButton) {
        DDGLog(@"show sync button");
        self.showingSyncButton = NO;
        UIBarButtonItem* progressItem = [[UIBarButtonItem alloc] initWithCustomView:self.pvSync];
        progressItem.enabled = NO;
        self.navigationItem.rightBarButtonItem = progressItem;
    } else {
        DDGLog(@"do nothing");
    }
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    DDGLog(@"keyPath='%@'", keyPath);
    if (object == _pull || object == _push) {
        unsigned completed = _pull.completed + _push.completed;
        unsigned total = _pull.total + _push.total;
        DDGLog(@"SYNC progress: %u / %u", completed, total);
        if (total > 0 && completed < total) {
            [self showSyncStatus];
            [self.pvSync setProgress:(completed / (float)total)];
        } else {
            [self showSyncButton];
        }
    }
}



#pragma mark -
#pragma mark - Couch table source delegate

// Customize the appearance of table view cells.
/** Called from -tableView:cellForRowAtIndexPath: just before it returns, giving the delegate a chance to customize the new cell. */
- (void)couchTableSource:(CouchUITableSource*)source
             willUseCell:(UITableViewCell*)cell
                  forRow:(CouchQueryRow*)row
{
    // Set the cell background and font:
    static UIColor* kBGColor;
    if (!kBGColor)
        kBGColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"item_background"]];
        
    cell.backgroundColor = kBGColor;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    cell.textLabel.font = [UIFont fontWithName: @"Helvetica" size:18.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    // Configure the cell contents. Our view function (see above) copies the document properties
    // into its value, so we can read them from there without having to load the document.
    // cell.textLabel.text is already set, thanks to setting up labelProperty above.
    NSDictionary* properties = row.value;
    BOOL checked = [[properties objectForKey:@"check"] boolValue];
    cell.textLabel.textColor = checked ? [UIColor grayColor] : [UIColor blackColor];
    cell.imageView.image = [UIImage imageNamed:
                            (checked ? @"list_area___checkbox___checked" : @"list_area___checkbox___unchecked")];
}
/** Allows delegate to return its own custom cell, just like -tableView:cellForRowAtIndexPath:.
 If this returns nil the table source will create its own cell, as if this method were not implemented. */
- (UITableViewCell *)couchTableSource:(CouchUITableSource*)source
                cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    DDGTrace();
    return nil;
}

/** Called after the query's results change, before the table view is reloaded. */
- (void)couchTableSource:(CouchUITableSource*)source
     willUpdateFromQuery:(CouchLiveQuery*)query;
{
    DDGTrace();
}

/** Called after the query's results change to update the table view. If this method is not implemented by the delegate, reloadData is called on the table view.*/
//- (void)couchTableSource:(CouchUITableSource*)source
//         updateFromQuery:(CouchLiveQuery*)query
//            previousRows:(NSArray *)previousRows;
//{
//    DDGLog(@"previousRows: %@", previousRows);
//}

/** Called if a CouchDB operation invoked by the source (e.g. deleting a document) fails. */
- (void)couchTableSource:(CouchUITableSource*)source
         operationFailed:(RESTOperation*)op;
{
    DDGTrace();
}

@end
