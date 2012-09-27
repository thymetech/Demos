//
//  CouchManager.h
//  MLWDemoTouchDB
//
//  Created by Mason Weems on 9/25/12.
//  Copyright (c) 2012 Mason Weems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CouchTouchDBServer;
@class CouchDatabase;
@interface CouchManager : NSObject

+ (CouchManager *) sharedCouchManager;
- (BOOL) startCouchbaseMobileServer:(NSError *__autoreleasing *)error;

@property (nonatomic, retain) CouchTouchDBServer *server;
@property (nonatomic, retain) CouchDatabase *database;
@property (nonatomic, retain) NSURL *urlRemoteServer;

@end
