//
//  ImageStore.m
//  TSNetwork
//
//  Created by zhaoxy on 11-11-20.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import "TSImageStore.h"
#import "TSImageDownloader.h"
#import "TSDBConnection.h"

static TSImageStore *instance = nil;

@interface TSImageStore(Private)

- (void)insertImage:(NSData*)buf forURL:(NSString*)url;

@end

@implementation TSImageStore

@synthesize maxConnection = _maxConnection;
@synthesize timeOutSeconds = _timeOutSeconds;

#pragma mark - Single-instance

+(TSImageStore *)sharedStore{
    if (!instance) {
        instance = [[TSImageStore alloc] init];
    }
    return instance;
}

#pragma mark - Initial and release

- (id)init {
    if ((self = [super init])) {
        cacheImages = [[NSMutableDictionary alloc] init];
        pending = [[NSMutableDictionary alloc] init];
        delegates = [[NSMutableDictionary alloc] init];
        badUrls = [[NSMutableArray alloc] init];
        //default queue length
        _maxConnection = 5;
        //default time out second
        _timeOutSeconds = 10;
    }
    return self;
}

- (void)dealloc {
    [badUrls release];
    [cacheImages release];
    [pending release];
    [delegates release];
    [super dealloc];
}

#pragma mark - Get image
//get image from database
- (id)getImageFromDB:(NSString*)url
{
    UIImage *image = nil;
    NSData *data = nil;
    static TSStatement *stmt = nil;
    if (stmt == nil) {
        stmt = [TSDBConnection statementWithQuery:"SELECT image FROM images WHERE url=?"];
        [stmt retain];
    }
    //PS: get data from 1, not 0
    [stmt bindString:url forIndex:1];
    if ([stmt step] == SQLITE_ROW) {
        //get image data from database
        data = [stmt getData:0];
        image = [UIImage imageWithData:data];
    }
    [stmt reset];
    
    if ([[url pathExtension] isEqualToString:@"gif"]) {
        return data;
    }else {
        return image;
    }
}

//get next image to download
- (void)getPendingImage:(TSImageDownloader *)sender {
    [pending removeObjectForKey:sender.requestURL];
    
    NSArray *keys = [pending allKeys];
    
    for (NSString *url in keys) {
        TSImageDownloader *dl = [pending objectForKey:url];
        //get waiting queue
        NSMutableArray *arr = [delegates objectForKey:url];
        if (arr == nil) {
            //if queue not exist, remove downloader
            [pending removeObjectForKey:url];
        }else if ([arr count] == 0) {
            //if queue is empty, delete the downloader and release queue
            [delegates removeObjectForKey:url];
            [pending removeObjectForKey:url];
        }else {
            if (dl.requestURL == nil) {
                //start download
                [dl get:url];
                break;
            }
        }
    }
}

//get image for url
- (id)getProfileImage:(NSString*)url delegate:(id)delegate{
    //url error
    if (![url isKindOfClass:[NSString class]]) {
        return nil;
    }
    //if url is bad then 
    if ([badUrls containsObject:url]) {
        return nil;
    }
    if (!delegate) {
        NSAssert(delegate==nil, @"image receiver not init");
    }
    //check whether the image is cached in memory
    id cacheImage = [cacheImages objectForKey:url];
    if (cacheImage) {
        return cacheImage;
    }
    //check whether the image is cached in database
    cacheImage = [self getImageFromDB:url];
    if (cacheImage) {
        [cacheImages setObject:cacheImage forKey:url];
        return cacheImage;
    }
    //if not, create downloader
    TSImageDownloader *dl = [pending objectForKey:url];
    if (dl == nil) {
        dl = [[[TSImageDownloader alloc] initWithDelegate:self] autorelease];
        dl.timeOutSeconds = _timeOutSeconds;
        [pending setObject:dl forKey:url];
    }
    
    NSMutableArray *arr = [delegates objectForKey:url];
    if (arr) {
        //add delegate to queue
        [arr addObject:delegate];
    }else {
        //if queue not exist, create one
        [delegates setObject:[NSMutableArray arrayWithObject:delegate] forKey:url];
    }
    //if not exceed the maximum length of queue, start donwload
    if ([pending count] <= _maxConnection && dl.requestURL == nil) {
        [dl get:url];
    }
    
    return nil;
}

#pragma mark - ImageDownloaderDelegate
//download image success
- (void)imageDownloaderDidSucceed:(TSImageDownloader *)sender {
    id cacheObject = nil;
    if ([[sender.requestURL pathExtension] isEqualToString:@"gif"]) {
        cacheObject = sender.buf;
    }else {
        cacheObject = [UIImage imageWithData:sender.buf];
    }
    
    if (cacheObject) {
        [self insertImage:sender.buf forURL:sender.requestURL];
        
        NSMutableArray *arr = [delegates objectForKey:sender.requestURL];
        if (arr) {
            for (id delegate in arr) {
                if ([delegate respondsToSelector:@selector(profileImageDidGetNewImage:)]) {
                    [delegate performSelector:@selector(profileImageDidGetNewImage:) withObject:cacheObject];
                }
            }
            [delegates removeObjectForKey:sender.requestURL];
        }
        [cacheImages setObject:cacheObject forKey:sender.requestURL];
    }else{
        if (![badUrls containsObject:sender.requestURL]) {
            [badUrls addObject:sender.requestURL];
        }
    }
    
    [self getPendingImage:sender];
}
//download image fail
- (void)imageDownloaderDidFail:(TSImageDownloader *)sender error:(NSError*)error {
    TSLog(@"image download fail:%@", [error description]);
    NSMutableArray *arr = [delegates objectForKey:sender.requestURL];
    if (arr) {
        for (id delegate in arr) {
            if ([delegate respondsToSelector:@selector(profileImageDidFailedGet)]) {
                [delegate performSelector:@selector(profileImageDidFailedGet)];
            }
        }
    }
    [self getPendingImage:sender];
}

//remove delegate by url
- (void)removeDelegate:(id)delegate forURL:(NSString *)key{
    NSMutableArray *arr = [delegates objectForKey:key];
    if (arr) {
        [arr removeObject:delegate];
        if ([arr count] == 0) {
            [delegates removeObjectForKey:key];
        }
    }
}

//remove all cache(memory, database) of certain image by url
- (void)releaseImage:(NSString*)url{
    id cacheObject = [cacheImages objectForKey:url];    
    if (cacheObject) {
        [cacheImages removeObjectForKey:url];
        [self removeImageForURL:url];
    }
}

//application receive memory warning
- (void)didReceiveMemoryWarning {
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    for (id key in cacheImages) {
        id cacheObject = [cacheImages objectForKey:key];
        if ([cacheObject retainCount] == 1) {
            TSLog(@"Release image %@", cacheObject);
            [array addObject:key];
        }
    }
    [cacheImages removeObjectsForKeys:array];
}

#pragma mark - Image Operation
//set whether the image can be delete automatically
- (void)setImageCanDelete:(BOOL)canDelete forURL:(NSString *)url {
    static TSStatement* setStmt = nil;
    if (setStmt == nil) {
        setStmt = [TSDBConnection statementWithQuery:"UPDATE images SET canDelete = ? where url = ?"];
        [setStmt retain];
    }
    [setStmt bindInt32:(int)canDelete forIndex:1];
    [setStmt bindString:url forIndex:2];
    
    [setStmt step];
    [setStmt reset];
}

//insert image into database
- (void)insertImage:(NSData*)buf forURL:(NSString*)url{ 
    static TSStatement* stmt = nil;
    if (stmt == nil) {
        stmt = [TSDBConnection statementWithQuery:"REPLACE INTO images VALUES(1, DATETIME('now'), ?, ?)"];
        [stmt retain];
    }
    [stmt bindData:buf forIndex:1];
    [stmt bindString:url forIndex:2];
    
    // Ignore error
    [stmt step];
    [stmt reset];
}

//remove certain image from database for url
- (void)removeImageForURL:(NSString *)url {
    static TSStatement* stmt = nil;
    if (stmt == nil) {
        stmt = [TSDBConnection statementWithQuery:"DELETE FROM images WHERE url = ?"];
        [stmt retain];
    }
    [stmt bindString:url forIndex:1];
    
    // Ignore error
    [stmt step];
    [stmt reset];
}

@end
