//
//  TSBaseClient.m
//  TSNetwork
//
//  Created by zhaoxy on 11-12-19.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import "TSBaseClient.h"
#import "Reachability.h"
#import "ASIDownloadCache.h"
#import "TSClientQueue.h"

@interface TSBaseClient ()

@property (nonatomic, assign)   BOOL hasError;
@property (nonatomic, assign)   int errorCode;
@property (nonatomic, retain, readwrite)   NSString *errorDetail;
@property (nonatomic, retain, readwrite)   NSString *errorMessage;

@end

@implementation TSBaseClient

@synthesize hasError = _hasError;
@synthesize errorDetail = _errorDetail, errorCode = _errorCode, errorMessage = _errorMessage;
@synthesize tempUserInfo = _tempUserInfo;
@synthesize dataFormat = _dataFormat;
@synthesize authoration = _authoration;
@synthesize timeOutSeconds = _timeOutSeconds;
@synthesize cacheData = _cacheData;
@synthesize isSequence = _isSequence;

#pragma mark - init and dealloc

- (id)initWithTarget:(id)aDelegate action:(SEL)anAction {
    if ((self = [super init])) {
        _action = anAction;
        _delegate = aDelegate;
        _authoration = YES;

        _dataFormat = TSDataFormatJSON;
        _timeOutSeconds = 30;
        _cacheData = NO;
    }
    return self;
}

- (void)dealloc {
    if (_request) {
        [_request clearDelegatesAndCancel];
        _request = nil;
    }
    if (_dataRequest) {
        [_dataRequest clearDelegatesAndCancel];
        _dataRequest = nil;
    }
    self.tempUserInfo = nil;
    self.errorDetail = nil;
    self.errorMessage = nil;
    [super dealloc];
}

#pragma mark - init and release HttpRequest

- (NSString *)getURL:(NSString *)urlStr withParams:(NSDictionary *)params {
    NSMutableString *tmpURL = [NSMutableString stringWithString:urlStr];
    [tmpURL appendString:@"?"];
    NSArray *keyArray = [params allKeys];
    for (int i=0; i<[keyArray count]; i++) {
        NSString *key = [keyArray objectAtIndex:i];
        id obj = [params objectForKey:key];
        if (i!=0) {
            [tmpURL appendString:@"&"];
        }
        [tmpURL appendFormat:@"%@=%@", key, [obj description]];
    }
    return tmpURL;
}

- (void)setHttpRequestGetWithUrl:(NSString *)urlStr params:(NSDictionary *)params {
    [self setHttpRequestGetWithUrl:[self getURL:urlStr withParams:params]];
}

//ASIHttpRequest Get
-(void)setHttpRequestGetWithUrl:(NSString *)urlStr {
    TSLog(@"%@", urlStr);
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if ([reach isReachable]) {
        NSURL *url = [NSURL URLWithString:urlStr];
        _request = [ASIHTTPRequest requestWithURL:url];
        [_request setUserInfo:[NSDictionary dictionaryWithObject:urlStr forKey:@"completeURL"]];
        [_request setTimeOutSeconds:_timeOutSeconds];
        [_request setShouldAttemptPersistentConnection:NO];
        [_request setDelegate:self];
        if (_isSequence) {
            [[TSClientQueue sharedQueue] addClient:_dataRequest];
        }else {
            [_request startAsynchronous];
        }
    }else {
        _hasError = YES;
        self.errorMessage = @"Network error. Please try again later.";
        self.errorDetail = @"Network error. Please try again later.";
        [self informDelegateWithObject:nil forURL:urlStr];
    }
}

//ASIHttpRequest Post
-(void)setHttpRequestPostWithUrl:(NSString *)urlStr params:(NSDictionary*)params{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if ([reach isReachable]) {
        NSURL *url = [NSURL URLWithString:urlStr];
        TSLog(@"params:%@", params);
        TSLog(@"%@",urlStr);
        _dataRequest = [ASIFormDataRequest requestWithURL:url];
        for (NSString *key in [params allKeys]) {
            [_dataRequest setPostValue:[params objectForKey:key] forKey:key];
        }
        [_dataRequest setUserInfo:[NSDictionary dictionaryWithObject:[self getURL:urlStr withParams:params] forKey:@"completeURL"]];
        [_dataRequest setTimeOutSeconds:_timeOutSeconds];
        [_dataRequest setShouldAttemptPersistentConnection:NO];
        [_dataRequest setDelegate:self];
        if (_isSequence) {
            [[TSClientQueue sharedQueue] addClient:_dataRequest];
        }else {
            [_dataRequest startAsynchronous];
        }
    }else {
        _hasError = YES;
        self.errorMessage = @"Network error. Please try again later.";
        self.errorDetail = @"Network error. Please try again later.";
        [self informDelegateWithObject:nil forURL:[self getURL:urlStr withParams:params]];
    }
}

//ASIHttpRequest JSON
-(void)setHttpRequestJSONWithUrl:(NSString *)urlStr jsonStr:(NSString *)jsonStr{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if ([reach isReachable]) {
        NSURL *url = [NSURL URLWithString:urlStr];
        _request = [ASIHTTPRequest requestWithURL:url];
        [_request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
        [_request addRequestHeader:@"Content-Type" value:@"application/json"];
        [_request appendPostData:[jsonStr  dataUsingEncoding:NSUTF8StringEncoding]];
        [_request setTimeOutSeconds:_timeOutSeconds];
        [_request setShouldAttemptPersistentConnection:NO];
        [_request setDelegate:self];
        if (_isSequence) {
            [[TSClientQueue sharedQueue] addClient:_dataRequest];
        }else {
            [_request startAsynchronous];
        }
    }else {
        _hasError = YES;
        self.errorMessage = @"Network error. Please try again later.";
        self.errorDetail = @"Network error. Please try again later.";
        [self informDelegateWithObject:nil forURL:urlStr];
    }
}

- (void)stopHttpRequest {
    if (_request) {
        [_request clearDelegatesAndCancel];
        _request = nil;
    }
    if (_dataRequest) {
        [_dataRequest clearDelegatesAndCancel];
        _dataRequest = nil;
    }
    [self autorelease];
}

- (void)informDelegateWithObject:(id)object forURL:(NSString *)url{
    //check whether server has returned data, if not, then return the cached data
    TSLog(@"informURL:%@",url);
    if (object) {
        if ([_delegate respondsToSelector:_action]) {
            [_delegate performSelector:_action withObject:self withObject:object];
        }
        if (_cacheData) {
            //save request
            [self insertResponse:object forURL:url];
        }
    }else {
        id savedObj = nil;
        if (_cacheData && _hasError) {
            savedObj = [self getResponseFromDB:url];
        }
        if ([_delegate respondsToSelector:_action]) {
            [_delegate performSelector:_action withObject:self withObject:savedObj];
        }
    }
}

#pragma mark - Judge whether the response is right
//subclass to get server response
- (void)response:(NSString *)responseString {
    
}

//must be overidden by subclass
- (BOOL)isResponseValid:(id)responseObj {
    NSAssert(NO, @"Subclasses need to overwrite this method");
    return YES;
}

//must be overidden by subclass
- (id)getData:(id)object {
    NSAssert(NO, @"Subclasses need to overwrite this method");
    return nil;
}

//subclass to get server error
- (NSString *)getErrorDetail:(id)object {
    return nil;
}

//must be overidden by subclass
- (int)getErrorCode:(id)object {
    NSAssert(NO, @"Subclasses need to overwrite this method");
    return 0;
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    int code = [request responseStatusCode];
    if (code >= 400) {
        _hasError = YES;
        self.errorMessage = @"Can't connect to server";
        self.errorDetail = @"Can't connect to server";
        [self informDelegateWithObject:nil forURL:[[request userInfo] objectForKey:@"completeURL"]];
    }else {
        NSString *responseString = [request responseString];
        //for subclass to get full server response
        [self response:responseString];
        id object = nil;
        NSError *error;
        TSLog(@"responseStr:%@", responseString);
        if (_dataFormat == TSDataFormatJSON) {
            responseString = [responseString stringByReplacingOccurrencesOfString:@"\\u0000" withString:@" "];
            NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            object = [data objectFromJSONData];
        }else {
            object = [XMLReader dictionaryForXMLString:responseString error:&error];
        }
        object = [self clearNull:object];
        TSLog(@"URL:%@, Data:%@", request.url, object);
        //clear error
        self.errorDetail = nil;
        self.errorMessage = nil;
        self.hasError = NO;
        if (!_authoration || [self isResponseValid:object]) {
            //use authoration
            if (_authoration) {
                [self informDelegateWithObject:[self getData:object] forURL:[[request userInfo] objectForKey:@"completeURL"]];
            }else {
                [self informDelegateWithObject:object forURL:[[request userInfo] objectForKey:@"completeURL"]];
            }
        }else{
            self.hasError = YES;
            self.errorMessage = @"Can't connect to server";
            self.errorDetail = @"Can't connect to server";
            if ([object isKindOfClass:[NSDictionary class]]) {
                self.errorDetail = [self getErrorDetail:object];
                self.errorCode = [self getErrorCode:object];
            }
            [self informDelegateWithObject:nil forURL:[[request userInfo] objectForKey:@"completeURL"]];
        }
    }
    _request = nil;
    _dataRequest = nil;
    [self autorelease];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    self.hasError = YES;
    NSError *error = [request error];
    self.errorMessage = @"Network error. Please try again later.";
    self.errorDetail = @"Network error. Please try again later.";
    TSLog(@"error:%@",[error description]);
    [self informDelegateWithObject:nil forURL:[[request userInfo] objectForKey:@"completeURL"]];
    _request = nil;
    _dataRequest = nil;
    [self autorelease];
}

#pragma mark - DataBase Operation

//insert request into local database
- (void)insertResponse:(id)response forURL:(NSString*)url{ 
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:response forKey:@"data"];
    [archiver finishEncoding];
    
    TSStatement* stmt = [TSDBConnection statementWithQuery:"REPLACE INTO requests VALUES(?, ?)"];
    [stmt bindString:url forIndex:1];
    [stmt bindData:data forIndex:2];
    
    [stmt step];
    [stmt reset];
    
    [data release];
    [archiver release];
}

//get request from local database
- (id)getResponseFromDB:(NSString*)url
{
    NSData *data = nil;
    TSStatement *stmt = [TSDBConnection statementWithQuery:"SELECT response FROM requests WHERE url=?"];
    
    [stmt bindString:url forIndex:1];
    if ([stmt step] == SQLITE_ROW) {
        data = [stmt getData:0];
    }
    [stmt reset];
    
    id dic = nil;
    if (data) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        dic = [unarchiver decodeObjectForKey:@"data"];
        [unarchiver finishDecoding];
        [unarchiver release];
    }
    return dic;
}

#pragma mark - Clear Null

//clear all null in the server response
- (id)clearNull:(id)object {
    id tmpObject = object;
    if ([object isKindOfClass:[NSArray class]]) {
        tmpObject = [NSMutableArray array];
        for (int i=0; i<[object count]; i++) {
            NSObject *obj = [object objectAtIndex:i];
            if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
                [tmpObject addObject:[self clearNull:obj]];
            }else {
                if (obj != [NSNull null]) {
                    [tmpObject addObject:obj];
                }
            }
        }
    }else if ([object isKindOfClass:[NSDictionary class]]) {
        tmpObject = [NSMutableDictionary dictionary];
        for (NSString *key in [object allKeys]) {
            NSObject *obj = [object objectForKey:key];
            if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
                [tmpObject setObject:[self clearNull:obj] forKey:key];
            }else {
                if (obj != [NSNull null]) {
                    [tmpObject setObject:obj forKey:key];
                }
            }
        }
    }
    return tmpObject;
}

@end
