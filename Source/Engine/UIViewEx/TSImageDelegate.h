//
//  TSImageDelegate.h
//  TSNetwork
//
//  Created by zhaoxy on 12-5-24.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import <Foundation/Foundation.h>

//默认显示图片的名称
static NSString *kTSDefaultImageSmall = @"TSDefaultSmallImage.png";
static NSString *kTSDefaultImageBig = @"TSDefaultBigImage.png";
static NSString *kTSDefaultImageCustom1 = @"TSDefaultCustom1Image.png";
static NSString *kTSDefaultImageCustom2 = @"TSDefaultCustom2Image.png";
static NSString *kTSDefaultImageCustom3 = @"TSDefaultCustom3Image.png";
static NSString *kTSDefaultImageCustom4 = @"TSDefaultCustom4Image.png";
static NSString *kTSDefaultImageCustom5 = @"TSDefaultCustom5Image.png";

typedef enum TSImageSizeType{
    TSImageSizeSmall,
    TSImageSizeBig,
    TSImageSizeCustom1,
    TSImageSizeCustom2,
    TSImageSizeCustom3,
    TSImageSizeCustom4,
    TSImageSizeCustom5,
}TSImageSizeType;

@protocol TSImageDelegate <NSObject>

@optional
//finish load image
- (void)imageDidLoadWithSize:(CGSize)size sender:(id)sender isDefault:(BOOL)isDefault;
//image download fail
- (void)imageDidLoadFailed:(id)sender;

@end
