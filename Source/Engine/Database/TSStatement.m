//
//  TSStatement.m
//  TSNetwork
//
//  Created by zhaoxy on 12-5-24.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import "TSStatement.h"

@implementation TSStatement

- (id)initWithDB:(sqlite3*)db query:(const char*)sql{
    self = [super init];
    
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        NSAssert2(0, @"Failed to prepare statement '%s' (%s)", sql, sqlite3_errmsg(db));
    }
    return self;
}

+ (id)statementWithDB:(sqlite3*)db query:(const char*)sql{
    return [[[TSStatement alloc] initWithDB:db query:sql] autorelease];
}

- (int)step{
    return sqlite3_step(stmt);
}

- (void)reset{
    sqlite3_reset(stmt);
}

- (void)dealloc{
    sqlite3_finalize(stmt);
    [super dealloc];
}

//
//
//
- (NSString*)getString:(int)index{
    return [NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, index)];    
}

- (int)getInt32:(int)index{
    return (int)sqlite3_column_int(stmt, index);
}

- (long long)getInt64:(int)index{
    return (long long)sqlite3_column_int(stmt, index);
}

- (NSData*)getData:(int)index{
    int length = sqlite3_column_bytes(stmt, index);
    return [NSData dataWithBytes:sqlite3_column_blob(stmt, index) length:length];    
}

//
//
//
- (void)bindString:(NSString*)value forIndex:(int)index{
    sqlite3_bind_text(stmt, index, [value UTF8String], -1, SQLITE_TRANSIENT);
}

- (void)bindInt32:(int)value forIndex:(int)index{
    sqlite3_bind_int(stmt, index, value);
}

- (void)bindInt64:(long long)value forIndex:(int)index{
    sqlite3_bind_int64(stmt, index, value);
}

- (void)bindData:(NSData*)value forIndex:(int)index{
    sqlite3_bind_blob(stmt, index, value.bytes, value.length, SQLITE_TRANSIENT);
}

@end
