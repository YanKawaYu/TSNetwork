//
//  ImageDownloader.m
//  TSNetwork
//
//  Created by zhaoxy on 11-11-20.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import "TSImageDownloader.h"

@interface NSObject (ImageDownloaderDelegate)
- (void)imageDownloaderDidSucceed:(TSImageDownloader*)sender;
- (void)imageDownloaderDidFail:(TSImageDownloader*)sender error:(NSError*)error;
@end

@implementation TSImageDownloader

@synthesize statusCode;
@synthesize requestURL;
@synthesize request = _request;
@synthesize buf = _buf;
@synthesize timeOutSeconds = _timeOutSeconds;

#pragma mark - initial and dealloc

- (id)initWithDelegate:(id)aDelegate
{
	self = [super init];
	delegate = aDelegate;
    statusCode = 0;
    _timeOutSeconds = 10;
	return self;
}

- (void)dealloc
{
    if (self.request) {
        [self.request clearDelegatesAndCancel];
        self.request = nil;
    }
    self.buf = nil;
    [requestURL release];
	[super dealloc];
}

#pragma mark - image download

- (void)get:(NSString*)aURL{
    statusCode = 0;
    
    self.requestURL = aURL;
    
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
	[URL autorelease];
    TSLog(@"start download image:%@", URL);
    
	//image url
	NSURL *finalURL = [NSURL URLWithString:URL];
	self.request = [ASIHTTPRequest requestWithURL:finalURL];
	self.request.delegate = self;
    //time out seconds
    [self.request setTimeOutSeconds:_timeOutSeconds];
    //support download resume
	[self.request setAllowResumeForFileDownloads:YES];
    //add to ASINetworkQueue queue
	[self.request startAsynchronous];
}

- (void)cancel{
    if (self.request) {
        [self.request clearDelegatesAndCancel];
        self.request = nil;
    }
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate method

//ASIHTTPRequestDelegate,download complete
- (void)requestFinished:(ASIHTTPRequest *)request {
    self.buf = [request responseData];
    [delegate imageDownloaderDidSucceed:self];
}
//ASIHTTPRequestDelegate,download fail
- (void)requestFailed:(ASIHTTPRequest *)request {
	[delegate imageDownloaderDidFail:self error:request.error];
}

@end
