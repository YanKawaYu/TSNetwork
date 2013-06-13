//
//  TSDBConnection.m
//  TSNetwork
//
//  Created by zhaoxy on 12-5-24.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import "TSDBConnection.h"

static sqlite3* theDatabase = nil;

//File name of database
#define MAIN_DATABASE_NAME @"TSDataBase"
//Optimize database after running certain times
#define Optimize_Count 150

@implementation TSDBConnection

//Add skip backup attribute to file, otherwise will be rejected by apple
+ (void)AddSkipBackupAttributeToFile:(NSURL*)url{   
    TSLog(@"addbackupAttribute:%@", url);
    u_int8_t b = 1;           
    setxattr([[url path] fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}

//init database when application finishes launching
+ (void)initializeDatabase {
    [TSDBConnection createEditableCopyOfDatabaseIfNeeded:NO];
    [TSDBConnection getSharedDatabase];
}

//Create a read/write database in cache directory
+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force
{
    //check whether database has exist
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    
    if (force) {
        [fileManager removeItemAtPath:writableDBPath error:&error];
    }
    
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    //copy the database file to the path
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
    //add skip backup attribute
    [TSDBConnection AddSkipBackupAttributeToFile:[NSURL URLWithString:[writableDBPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

//open database
+ (sqlite3*)openDatabase:(NSString*)dbFilename{
    sqlite3* instance;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dbFilename];
    if (sqlite3_open([path UTF8String], &instance) != SQLITE_OK) {
        sqlite3_close(instance);
        TSLog(@"Failed to open database. (%s)", sqlite3_errmsg(instance));
        return nil;
    }        
    return instance;
}

//singleton
+ (sqlite3*)getSharedDatabase{
    if (theDatabase == nil) {
        theDatabase = [self openDatabase:MAIN_DATABASE_NAME];
        if (theDatabase == nil) {
            [TSDBConnection createEditableCopyOfDatabaseIfNeeded:YES];
            TSLog(@"Local cached database error, recreating database...");
        }
    }
    return theDatabase;
}

//clear all local image cache
+ (void)deleteImageCache {
    char *errmsg;
    [self getSharedDatabase];
    
    if (sqlite3_exec(theDatabase, "DELETE FROM images; VACUUM;", NULL, NULL, &errmsg) != SQLITE_OK) {
        //ignore error
        TSLog(@"Error: failed to cleanup chache (%s)", errmsg);
    }
}

//clear all local request cache
+ (void)deleteResponseCache {
    char *errmsg;
    [self getSharedDatabase];
    
    if (sqlite3_exec(theDatabase, "DELETE FROM requests; VACUUM;", NULL, NULL, &errmsg) != SQLITE_OK) {
        //ignore error
        TSLog(@"Error: failed to cleanup chache (%s)", errmsg);
    }
}

#pragma mark - Cleanup

const char *cleanup_sql =
"BEGIN;"
"DELETE FROM images WHERE canDelete = 1 and updated_at <= (SELECT updated_at FROM images WHERE canDelete = 1 order by updated_at LIMIT 1 OFFSET 5000);"
"COMMIT";

const char *optimize_sql = "VACUUM; ANALYZE";

//close database
+ (void)closeDatabase{
    char *errmsg;
    if (theDatabase) {
        if (sqlite3_exec(theDatabase, cleanup_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
            //ignore error
            TSLog(@"Error: failed to cleanup chache (%s)", errmsg);
        }
        
      	int launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
        TSLog(@"launchCount %d", launchCount);
        //Optimize database after running certain times
        if (launchCount-- <= 0) {
            TSLog(@"Optimize database...");
            if (sqlite3_exec(theDatabase, optimize_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
                TSLog(@"Error: failed to cleanup chache (%s)", errmsg);
            }
            launchCount = Optimize_Count;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:launchCount forKey:@"launchCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];        
        sqlite3_close(theDatabase);
        theDatabase = nil;
    }
}

#pragma mark - Common Utilities

+ (void)beginTransaction{
    char *errmsg;     
    sqlite3_exec(theDatabase, "BEGIN", NULL, NULL, &errmsg);     
}

+ (void)commitTransaction{
    char *errmsg;     
    sqlite3_exec(theDatabase, "COMMIT", NULL, NULL, &errmsg);     
}

+ (TSStatement*)statementWithQuery:(const char *)sql{
    if (!theDatabase) {
        [TSDBConnection getSharedDatabase];
    }
    TSStatement* stmt = [TSStatement statementWithDB:theDatabase query:sql];
    return stmt;
}

@end
