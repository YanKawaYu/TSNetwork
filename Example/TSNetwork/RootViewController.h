//
//  RootViewController.h
//  TSNetwork
//
//  Created by zhaoxy on 13-6-13.
//  Copyright (c) 2013年 TSinghua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSImageView.h"
#import "DemoClient.h"

@interface RootViewController : UIViewController {
    DemoClient *_demoClient;
}

@property (retain, nonatomic) IBOutlet UILabel *cityLabel;
@property (retain, nonatomic) IBOutlet TSImageView *imageView;
@property (retain, nonatomic) IBOutlet TSImageView *gifImageView;

- (IBAction)getXMLData:(id)sender;
- (IBAction)getJSONData:(id)sender;
- (IBAction)getImage:(id)sender;
- (IBAction)getGif:(id)sender;
- (IBAction)clearImageCache:(id)sender;
- (IBAction)clearRequestCache:(id)sender;

@end
