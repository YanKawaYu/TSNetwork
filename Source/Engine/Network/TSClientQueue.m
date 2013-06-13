//
//  TSClientQueue.m
//  TSNetwork
//
//  Created by zhaoxy on 12-8-4.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//
//

#import "TSClientQueue.h"

static TSClientQueue *instance = nil;

@implementation TSClientQueue

#pragma mark - Single-instance

//singleton
+ (TSClientQueue *)sharedQueue{
    if (!instance) {
        instance = [[TSClientQueue alloc] init];
    }
    return instance;
}

#pragma mark - init 

- (id)init {
    if ((self = [super init])) {
        _networkQueue = [[ASINetworkQueue alloc] init];
        [_networkQueue setMaxConcurrentOperationCount:1];
        [_networkQueue setShouldCancelAllRequestsOnFailure:NO];
        [_networkQueue go];
    }
    return self;
}

- (void)addClient:(ASIHTTPRequest *)request {
    [_networkQueue addOperation:(NSOperation *)request];
}

- (void)stopAllClient {
    [_networkQueue cancelAllOperations];
}

@end
