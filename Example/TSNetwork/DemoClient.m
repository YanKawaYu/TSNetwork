//
//  DemoClient.m
//  TSNetwork
//
//  Created by zhaoxy on 13-6-13.
//  Copyright (c) 2013年 TSinghua. All rights reserved.
//

#import "DemoClient.h"

@implementation DemoClient

+ (DemoClient *)clientWithTarget:(id)target action:(SEL)action
{
    return [[DemoClient alloc] initWithTarget:target action:action];
}

- (void)httpPostWithURL:(NSString *)url params:(NSDictionary *)params {
    TSLog(@"url:%@", url);
    TSLog(@"params:%@", params);
    [self setHttpRequestPostWithUrl:url params:params];
}

#pragma mark - 覆盖方法

//子类必须覆盖该方法
- (BOOL)isResponseValid:(id)responseObj
{
    BOOL returnValue = NO;
    if ([responseObj isKindOfClass:[NSDictionary class]]) {
        if (self.dataFormat == TSDataFormatXML) {
            if ([[[responseObj objectForKey:@"GeocoderSearchResponse"] objectForKey:@"status"] isEqualToString:@"OK"]) {
                returnValue = YES;
            }
        }else {
            if ([[responseObj objectForKey:@"status"] isEqualToString:@"OK"]) {
                returnValue = YES;
            }
        }
    }
    return returnValue;
}

//子类必须覆盖该方法
- (id)getData:(id)object{
    id data = nil;
    if ([object isKindOfClass:[NSDictionary class]]) {
        if (self.dataFormat == TSDataFormatXML) {
            data = [[object objectForKey:@"GeocoderSearchResponse"] objectForKey:@"result"];
        }else {
            data = [object objectForKey:@"result"];
        }
    }
    return data;
}

//子类必须覆盖该方法
- (int)getErrorCode:(id)object{
    int errorCode = 0;
    if ([object isKindOfClass:[NSDictionary class]]) {
        if (self.dataFormat == TSDataFormatXML) {
            errorCode =  [[[object objectForKey:@"GeocoderSearchResponse"] objectForKey:@"status"] intValue];
        }else {
            errorCode =  [[object objectForKey:@"status"] intValue];
        }
    }
    return errorCode;
}

//服务器错误信息
//- (NSString *)getErrorDetail:(id)object {
//    NSString *serverMessage = nil;
//    if ([object isKindOfClass:[NSDictionary class]]) {
//        if (self.dataFormat == TSDataFormatXML) {
//            serverMessage = [[object objectForKey:@"GeocoderSearchResponse"] objectForKey:@"status"];
//        }else {
//            serverMessage = [object objectForKey:@"status"];
//        }
//    }
//    return serverMessage;
//}

////服务器返回
//- (void)response:(NSString *)responseString {
//    TSLog(@"server response:%@", responseString);
//}

#pragma mark - Server API

//通过百度地图获取位置
- (void)getLocationWithLat:(double)lat lon:(double)lon format:(NSString *)format {
    NSString *urlStr = [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder?output=%@&location=%lf,%lf", format, lat, lon];
    [self setHttpRequestGetWithUrl:urlStr];
}

@end
