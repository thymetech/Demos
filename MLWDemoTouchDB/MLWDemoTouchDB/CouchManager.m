//
//  CouchManager.m
//  MLWDemoTouchDB
//
//  Created by Mason Weems on 9/25/12.
//  Copyright (c) 2012 Mason Weems. All rights reserved.
//

#import "CouchManager.h"
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchTouchDBServer.h>

#define CLASS_DEBUG 1
#import "DDGMacros.h"

@implementation CouchManager

+ (CouchManager *)sharedCouchManager {
    static dispatch_once_t predicate;
    __strong static CouchManager * sharedCouchManager = nil;
    dispatch_once( &predicate, ^{
        sharedCouchManager = [[self alloc] init];
    });
    return sharedCouchManager;
}

- (id) init {
    if ( (self = [super init]) ) {
        gCouchLogLevel = 2;
        DDGLog(@"gCouchLogLevel=%i", gCouchLogLevel);
    }
    return self;
}

- (id) initWithURL:(NSURL *)url {
    
    DDGTrace();
    if (self = [self init]) {
        self.urlRemoteServer = url;
    }
    return self;
}

- (CouchTouchDBServer *) server;
{
    if (!_server) {
        if (self.urlRemoteServer) {
            DDGLog(@"Create server with remote server '%@'", [self.urlRemoteServer absoluteString]);
            self.server = [[CouchTouchDBServer alloc] initWithURL:self.urlRemoteServer];
        } else {
            DDGLog(@"Create server without remote server");
            self.server = [[CouchTouchDBServer alloc] init];
        }
    }
    return _server;
}

//#define CouchManagerDatabaseName @"CouchManagerDatabase"
#define CouchManagerDatabaseName @"grocery-sync"

- (BOOL) startCouchbaseMobileServer:(NSError *__autoreleasing *)error;
{
    DDGTrace();
    CouchTouchDBServer *touchDBServer = self.server;
    
//    if (self.urlRemoteServer) {
//        DDGLog(@"Create server with remote server '%@'", [self.urlRemoteServer absoluteString]);
//        touchDBServer = [[CouchTouchDBServer alloc] initWithURL:self.urlRemoteServer];
//    } else {
//        DDGLog(@"Create server without remote server");
//        touchDBServer = [[CouchTouchDBServer alloc] init];
//    }

    if (touchDBServer.error) {
        *error = touchDBServer.error;
        [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Could not create server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return NO;
    }
    
    self.database = [self.server databaseNamed:CouchManagerDatabaseName];
    
    if (!self.urlRemoteServer) {
        if (![self.database ensureCreated:error]) {
            DDGLog(@"ERROR: Could not create local database");
            [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Could not create local database" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return NO;
        } else {
            DDGLog(@"Successfully created local database");
        }
    } else {
        DDGLog(@"Using remote server at url '%@'", [self.urlRemoteServer absoluteString]);
    }
    
    self.database.tracksChanges = YES;
    
    return YES;
}

@end
