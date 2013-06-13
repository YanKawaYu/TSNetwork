//
//  TSBaseClient.h
//  TSNetwork
//
//  Created by zhaoxy on 11-12-19.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "XMLReader.h"
#import "TSNetwork.h"

typedef enum TSDataFormat {
    TSDataFormatJSON,
    TSDataFormatXML
}TSDataFormat;

@interface TSBaseClient : NSObject <ASIHTTPRequestDelegate>{
    SEL         _action;
    id          _delegate;
    
    //Request
    ASIHTTPRequest *_request;
    ASIFormDataRequest *_dataRequest;
}

//whether request has error
@property (nonatomic, readonly)     BOOL hasError;
//error message(defined by client)
@property (nonatomic, readonly, retain)     NSString* errorMessage;
//error detail(return by server)
@property (nonatomic, readonly, retain)     NSString* errorDetail;
//error code
@property (nonatomic, readonly)     int errorCode;
//temp data
@property (nonatomic, retain)       NSDictionary *tempUserInfo;
//the format of server response(JSON, XML)
@property (nonatomic, assign)       TSDataFormat dataFormat;
//whether to check server data
@property (nonatomic, assign)       BOOL authoration;
//time out seconds
@property (nonatomic, assign)       int timeOutSeconds;
//whether to cache request
@property (nonatomic, assign)       BOOL cacheData;
//whether to add request to queue, and excute in order
@property (nonatomic, assign)       BOOL isSequence;

//init
- (id)initWithTarget:(id)delegate action:(SEL)action;
//stop
- (void)stopHttpRequest;
//Get method
- (void)setHttpRequestGetWithUrl:(NSString *)urlStr;
//Extended Get method, joint param automatically
- (void)setHttpRequestGetWithUrl:(NSString *)urlStr params:(NSDictionary *)params;
//Post method
- (void)setHttpRequestPostWithUrl:(NSString *)urlStr params:(NSDictionary*)params;
//Pass JSON format data to server
-(void)setHttpRequestJSONWithUrl:(NSString *)urlStr jsonStr:(NSString *)jsonStr;
//must be overidden by subclass
- (BOOL)isResponseValid:(id)responseObj;
//must be overidden by subclass
- (id)getData:(id)object;
//must be overidden by subclass
- (int)getErrorCode:(id)object;
//subclass to get server error
- (NSString *)getErrorDetail:(id)object;
//subclass to get server response
- (void)response:(NSString *)responseString;

@end
