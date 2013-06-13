//
//  TSImageButton.m
//  TSNetwork
//
//  Created by zhaoxy on 12-5-24.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TSImageButton.h"
#import "TSImageStore.h"

@implementation TSImageButton

@synthesize imageURL = _imageURL;
@synthesize sizeType = _sizeType;
@synthesize delegate = _delegate;
@synthesize isBackground = _isBackground;
@synthesize userInfo = _userInfo;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _receiver = [[TSImageStoreReceiver alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _receiver = [[TSImageStoreReceiver alloc] init];
    }
    return self;
}

- (void)dealloc{
    //remove delegate
    _receiver.imageContainer = nil;
    [[TSImageStore sharedStore] removeDelegate:_receiver forURL:_imageURL];
    [_receiver release];
    self.imageURL = nil;
    [super dealloc];
}

//subclass to change image
- (UIImage *)changeImage:(UIImage *)image {
    return image;
}

//get image by url, if image not downloaded then return no and display default image
- (BOOL)getImage:(NSString*)url{
    self.imageURL = url;
    //whether url is local path
    UIImage *localImage = [UIImage imageWithContentsOfFile:url];
    id image;
    BOOL isDefault = NO;
    if (localImage) {
        image = localImage;
    }else{
        //whether image has already been downloaded
        image = [[TSImageStore sharedStore] getProfileImage:url delegate:_receiver];
        _receiver.imageContainer = self;
        if (!image) {
            isDefault = YES;
            if (_sizeType == TSImageSizeBig) {
                image = [UIImage imageNamed:kTSDefaultImageBig];
            }else if (_sizeType == TSImageSizeSmall) {
                image = [UIImage imageNamed:kTSDefaultImageSmall];
            }else if (_sizeType == TSImageSizeCustom1) {
                image = [UIImage imageNamed:kTSDefaultImageCustom1];
            }else if (_sizeType == TSImageSizeCustom2) {
                image = [UIImage imageNamed:kTSDefaultImageCustom2];
            }else if (_sizeType == TSImageSizeCustom3) {
                image = [UIImage imageNamed:kTSDefaultImageCustom3];
            }else if (_sizeType == TSImageSizeCustom4) {
                image = [UIImage imageNamed:kTSDefaultImageCustom4];
            }else if (_sizeType == TSImageSizeCustom5) {
                image = [UIImage imageNamed:kTSDefaultImageCustom5];
            }
        }
    }
    UIImage *finalImage;
    if ([image isKindOfClass:[UIImage class]]) {
        finalImage = [self changeImage:image];
    }else {
        finalImage = [self changeImage:[UIImage imageWithData:image]];
    }
    if (_isBackground) {
        [self setBackgroundImage:finalImage forState:UIControlStateNormal];
    }else {
        [self setImage:finalImage forState:UIControlStateNormal];
    }
    if ([_delegate respondsToSelector:@selector(imageDidLoadWithSize:sender:isDefault:)]) {
        [_delegate imageDidLoadWithSize:((UIImage *)finalImage).size sender:self isDefault:isDefault];
    }
    return !isDefault;
}

//update image when download complete
- (void)imageDownloadDidSucceed:(id)image {
    if ([image isKindOfClass:[UIImage class]]) {
        UIImage *finalImage = [self changeImage:image];
        CATransition *animation = [CATransition animation];
        animation.duration = 0.5;
        animation.type = kCATransitionFade;
        [self.layer addAnimation:animation forKey:@"imageFade"];
        if (_isBackground) {
            [self setBackgroundImage:finalImage forState:UIControlStateNormal];
        }else {
            [self setImage:finalImage forState:UIControlStateNormal];
        }
        if ([_delegate respondsToSelector:@selector(imageDidLoadWithSize:sender:isDefault:)]) {
            [_delegate imageDidLoadWithSize:((UIImage *)finalImage).size sender:self isDefault:NO];
        }
    }
}

//image download fail
- (void)imageDownloadDidFail {
    if ([_delegate respondsToSelector:@selector(imageDidLoadFailed:)]) {
        [_delegate imageDidLoadFailed:self];
    }
}

//remove delegate (use when added on tableview cell)
- (void)prepareForReuse{
    _receiver.imageContainer = nil;
    [[TSImageStore sharedStore] removeDelegate:_receiver forURL:_imageURL];
    self.imageURL = nil;
}

@end
