//
//  TSStatement.h
//  TSNetwork
//
//  Created by zhaoxy on 12-5-24.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface TSStatement : NSObject{
    sqlite3_stmt*   stmt;
}

//init a SQL statement
+ (id)statementWithDB:(sqlite3*)db query:(const char*)sql;
- (id)initWithDB:(sqlite3*)db query:(const char*)sql;

// method
- (int)step;
- (void)reset;

// Getter
- (NSString*)getString:(int)index;
- (int)getInt32:(int)index;
- (long long)getInt64:(int)index;
- (NSData*)getData:(int)index;

// Binder
- (void)bindString:(NSString*)value forIndex:(int)index;
- (void)bindInt32:(int)value forIndex:(int)index;
- (void)bindInt64:(long long)value forIndex:(int)index;
- (void)bindData:(NSData*)data forIndex:(int)index;


@end
