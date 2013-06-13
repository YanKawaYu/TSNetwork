//
//  RootViewController.m
//  TSNetwork
//
//  Created by zhaoxy on 13-6-13.
//  Copyright (c) 2013年 TSinghua. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)getXMLData:(id)sender {
    if (!_demoClient) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _demoClient = [DemoClient clientWithTarget:self action:@selector(locationDataReceived:obj:)];
        _demoClient.dataFormat = TSDataFormatXML;
        [_demoClient getLocationWithLat:39.92 lon:116.46 format:@"xml"];
    }
}

- (IBAction)getJSONData:(id)sender {
    if (!_demoClient) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _demoClient = [DemoClient clientWithTarget:self action:@selector(locationDataReceived:obj:)];
        [_demoClient getLocationWithLat:39.92 lon:116.46 format:@"json"];
    }
}

- (void)locationDataReceived:(DemoClient *)sender obj:(NSObject *)obj {
    _demoClient = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (sender.hasError) {
        TSLog(@"error:%@", sender.errorDetail);
    }
    if (![obj isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _cityLabel.text = [(NSDictionary *)obj objectForKey:@"formatted_address"];
}

- (IBAction)getImage:(id)sender {
    [_imageView getImage:@"http://h.hiphotos.baidu.com/album/w%3D2048/sign=34a2c6ca14ce36d3a20484300ecb3a87/3801213fb80e7bec3bf039f12e2eb9389b506bf3.jpg"];
}

- (IBAction)getGif:(id)sender {
    _gifImageView.canPlayGif = YES;
    [_gifImageView getImage:@"http://img4.duitang.com/uploads/item/201204/18/20120418172313_PzMYR.thumb.600_0.gif"];
}

- (IBAction)clearImageCache:(id)sender {
    [TSDBConnection deleteImageCache];
}

- (IBAction)clearRequestCache:(id)sender {
    [TSDBConnection deleteResponseCache];
}

- (void)dealloc {
    [_cityLabel release];
    [_imageView release];
    [_gifImageView release];
    [super dealloc];
}
@end
