//
//  ImageDownloader.h
//  TSNetwork
//
//  Created by zhaoxy on 11-11-20.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "TSNetwork.h"

@interface TSImageDownloader : NSObject <ASIHTTPRequestDelegate> {
    id                  delegate;
    NSString*           requestURL;
    int                 statusCode;
}

@property (nonatomic, assign) int statusCode;
@property (nonatomic, retain) NSString* requestURL;
@property (nonatomic, assign) ASIHTTPRequest* request;
@property (nonatomic, retain) NSData *buf;
//Time out seconds for downloading image
@property (nonatomic, assign) int timeOutSeconds;

- (id)initWithDelegate:(id)aDelegate;
- (void)get:(NSString*)URL;

@end
