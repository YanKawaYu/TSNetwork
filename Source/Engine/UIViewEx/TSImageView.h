//
//  TSImageView.h
//  TSNetwork
//
//  Created by zhaoxy on 12-5-24.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import "TSImageDelegate.h"
#import "TSImageStoreReceiver.h"

@interface TSImageView : UIImageView {
    TSImageStoreReceiver    *_receiver;
    
    CGSize              _gifSize;
    CGImageSourceRef    _gif;
	size_t              _gifIndex;
	size_t              _gifCount;
    NSDictionary        *_gifProperties;
	NSTimer             *_gifTimer;
}

@property (nonatomic, assign) id<TSImageDelegate> delegate;
@property (nonatomic, retain) NSString *imageURL;
//image size type (for default image)
@property (nonatomic, assign) TSImageSizeType sizeType;
//whether to play gif
@property (nonatomic, assign) BOOL canPlayGif;
//custom user info
@property (nonatomic, assign) id userInfo;

//get image by url, if image not downloaded then return no and display default image
- (BOOL)getImage:(NSString*)url;
//remove delegate (use when added on tableview cell)
- (void)prepareForReuse;
//get image size
- (CGSize)getImageSize;
//subclass to change image (for special use)
- (UIImage *)changeImage:(UIImage *)image;

@end
