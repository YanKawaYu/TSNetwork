//
//  TSDBConnection.h
//  TSNetwork
//
//  Created by zhaoxy on 12-5-24.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "TSStatement.h"
#import "TSNetwork.h"

@interface TSDBConnection : NSObject

//create database, if param is true then delete old database first
+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force;
//get and open singleton database, if not exist then create one
+ (sqlite3*)getSharedDatabase;
//init database
+ (void)initializeDatabase;
//close database
+ (void)closeDatabase;
//clear all local image cache
+ (void)deleteImageCache;
//clear all local request cache
+ (void)deleteResponseCache;

//statement operation
+ (void)beginTransaction;
+ (void)commitTransaction;
//create SQL statement
+ (TSStatement*)statementWithQuery:(const char*)sql;

@end
