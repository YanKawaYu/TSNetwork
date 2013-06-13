//
//  TSImageStoreReceiver.m
//  TSNetworkDemo
//
//  Created by zhaoxy on 12-6-10.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import "TSImageStoreReceiver.h"

@implementation TSImageStoreReceiver

@synthesize imageContainer;

- (void)dealloc
{
    imageContainer = nil;
    [super dealloc];
}

//image download success
- (void)profileImageDidGetNewImage:(id)image {
    if (imageContainer) {
        if ([imageContainer respondsToSelector:@selector(imageDownloadDidSucceed:)]) {
            [imageContainer performSelector:@selector(imageDownloadDidSucceed:) withObject:image];
        }
    }
}

//image download fail
- (void)profileImageDidFailedGet {
    if (imageContainer) {
        if ([imageContainer respondsToSelector:@selector(imageDownloadDidFail)]) {
            [imageContainer performSelector:@selector(imageDownloadDidFail)];
        }
    }
}

@end
