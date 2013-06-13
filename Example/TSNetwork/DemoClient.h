//
//  DemoClient.h
//  TSNetwork
//
//  Created by zhaoxy on 13-6-13.
//  Copyright (c) 2013年 TSinghua. All rights reserved.
//

#import "TSBaseClient.h"

@interface DemoClient : TSBaseClient

+ (DemoClient *)clientWithTarget:(id)target action:(SEL)action;

- (void)getLocationWithLat:(double)lat lon:(double)lon format:(NSString *)format;

@end
