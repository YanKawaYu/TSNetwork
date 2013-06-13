//
//  TSImageView.m
//  TSNetwork
//
//  Created by zhaoxy on 12-5-24.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import "TSImageView.h"
#import "TSImageStore.h"
#import <QuartzCore/QuartzCore.h>

@implementation TSImageView

@synthesize imageURL = _imageURL;
@synthesize sizeType = _sizeType;
@synthesize canPlayGif = _canPlayGif;
@synthesize delegate = _delegate;
@synthesize userInfo = _userInfo;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _receiver = [[TSImageStoreReceiver alloc] init];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    if ((self = [super initWithImage:image])) {
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

-(void)dealloc{
    if (_gif) {
        CFRelease(_gif);
    }
	[_gifProperties release];
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
        image = [[TSImageStore sharedStore] getProfileImage:url delegate:_receiver];
        _receiver.imageContainer = self;
        if (!image) {
            isDefault = YES;
            if (_sizeType == TSImageSizeBig) {
                image = [UIImage imageNamed:kTSDefaultImageBig];
            }
            else if (_sizeType == TSImageSizeSmall) {
                image = [UIImage imageNamed:kTSDefaultImageSmall];
            }
            else if (_sizeType == TSImageSizeCustom1) {
                image = [UIImage imageNamed:kTSDefaultImageCustom1];
            }
            else if (_sizeType == TSImageSizeCustom2) {
                image = [UIImage imageNamed:kTSDefaultImageCustom2];
            }
            else if (_sizeType == TSImageSizeCustom3) {
                image = [UIImage imageNamed:kTSDefaultImageCustom3];
            }
            else if (_sizeType == TSImageSizeCustom4) {
                image = [UIImage imageNamed:kTSDefaultImageCustom4];
            }
            else if (_sizeType == TSImageSizeCustom5) {
                image = [UIImage imageNamed:kTSDefaultImageCustom5];
            }
            NSAssert(image, @"Default Image not exist");
        }
    }
    //whether to play gif
    [self stop];
    if ([image isKindOfClass:[UIImage class]]) {
        UIImage *finalImage = [self changeImage:image];
        [self setImage:finalImage];
    }else {
        if (_canPlayGif) {
            [self playGIFWithData:image];
        }else {
            [self setImage:[UIImage imageWithData:image]];
        }
    }
    if ([_delegate respondsToSelector:@selector(imageDidLoadWithSize:sender:isDefault:)]) {
        [_delegate imageDidLoadWithSize:[self getImageSize] sender:self isDefault:isDefault];
    }
    return !isDefault;
}

//update image when download complete
- (void)imageDownloadDidSucceed:(id)image {
    //whether to play gif
    [self stop];
    if ([image isKindOfClass:[UIImage class]]) {
        CATransition *animation = [CATransition animation];
        animation.duration = 0.5;
        animation.type = kCATransitionFade;
        [self.layer addAnimation:animation forKey:@"imageFade"];
        UIImage *finalImage = [self changeImage:image];
        [self setImage:finalImage];
    }else {
        if (_canPlayGif) {
            [self playGIFWithData:image];
        }else {
            UIImage *tmpImg = [UIImage imageWithData:image];
            [self setImage:tmpImg];
        }
    }
    if ([_delegate respondsToSelector:@selector(imageDidLoadWithSize:sender:isDefault:)]) {
        [_delegate imageDidLoadWithSize:[self getImageSize] sender:self isDefault:NO];
    }
}

//download fail
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

//get image size
- (CGSize)getImageSize {
    if (_gifTimer) {
        return _gifSize;
    }else {
        return self.image.size;
    }
}

#pragma mark - Gif

//play gif image
- (void)playGIFWithData:(NSData *)data{
    //play duration of gif
    NSTimeInterval duration = [self durationForGifData:data];
    //play times of gif
    _gifProperties = [[NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
                                                 forKey:(NSString *)kCGImagePropertyGIFDictionary] retain];
    //create gif by data
    _gif = CGImageSourceCreateWithData((CFDataRef)data, (CFDictionaryRef)_gifProperties);
    //get gif image frame
    _gifCount =CGImageSourceGetCount(_gif);
    //get gif image size
    CGFloat width = 0.0f, height = 0.0f;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(_gif, 0, NULL);
    if (imageProperties != NULL) {
        CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        if (widthNum != NULL) {
            CFNumberGetValue(widthNum, kCFNumberFloatType, &width);
        }
        
        CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        if (heightNum != NULL) {
            CFNumberGetValue(heightNum, kCFNumberFloatType, &height);
        }
        
        CFRelease(imageProperties);
    }
    _gifSize = CGSizeMake(width, height);
    //start timer
    _gifTimer = [NSTimer scheduledTimerWithTimeInterval:(duration/_gifCount) target:self selector:@selector(play) userInfo:nil repeats:YES];
    [_gifTimer fire];
    [[NSRunLoop mainRunLoop] addTimer:_gifTimer forMode:NSRunLoopCommonModes];
}

-(void)play
{
	_gifIndex ++;
	_gifIndex = _gifIndex % _gifCount;
	CGImageRef ref = CGImageSourceCreateImageAtIndex(_gif, _gifIndex, (CFDictionaryRef)_gifProperties);
	self.layer.contents = (id)ref;
    CGImageRelease(ref);
}

-(void)stop
{
    [_gifTimer invalidate];
	_gifTimer = nil;
}

//get duration of gif image
- (NSTimeInterval)durationForGifData:(NSData *)data {
    char graphicControlExtensionStartBytes[] = {0x21,0xF9,0x04};
    double duration=0;
    NSRange dataSearchLeftRange = NSMakeRange(0, data.length);
    while(YES){
        NSRange frameDescriptorRange = [data rangeOfData:[NSData dataWithBytes:graphicControlExtensionStartBytes 
                                                                        length:3] 
                                                 options:NSDataSearchBackwards
                                                   range:dataSearchLeftRange];
        if(frameDescriptorRange.location!=NSNotFound){
            NSData *durationData = [data subdataWithRange:NSMakeRange(frameDescriptorRange.location+4, 2)];
            unsigned char buffer[2];
            [durationData getBytes:buffer];
            double delay = (buffer[0] | buffer[1] << 8);
            duration += delay;
            dataSearchLeftRange = NSMakeRange(0, frameDescriptorRange.location);
        }else{
            break;
        }
    }
    return duration/100;
}
//stop timer when removed
-(void)removeFromSuperview
{
	[_gifTimer invalidate];
	_gifTimer = nil;
	[super removeFromSuperview];
}

@end
