//
//  TSImageButton.h
//  TSNetwork
//
//  Created by zhaoxy on 12-5-24.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSImageDelegate.h"
#import "TSImageStoreReceiver.h"

@interface TSImageButton : UIButton {
    TSImageStoreReceiver    *_receiver;
}

@property (nonatomic, assign) id<TSImageDelegate> delegate;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, assign) TSImageSizeType sizeType;
@property (nonatomic, assign) BOOL isBackground;
//custom user info
@property (nonatomic, assign) id userInfo;

//get image by url, if image not downloaded then return no and display default image
- (BOOL)getImage:(NSString*)url;
//remove delegate (use when added on tableview cell)
- (void)prepareForReuse;
//subclass to change image
- (UIImage *)changeImage:(UIImage *)image;

@end
