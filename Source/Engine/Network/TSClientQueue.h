//
//  TSClientQueue.h
//  TSNetwork
//
//  Created by zhaoxy on 12-8-4.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

@interface TSClientQueue : NSObject {
    ASINetworkQueue *_networkQueue;
}

+ (TSClientQueue *)sharedQueue;
- (void)addClient:(ASIHTTPRequest *)request;
- (void)stopAllClient;

@end
