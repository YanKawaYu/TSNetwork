TSNetwork
=========

a framework to ease network operations including request and image download

## Introduction

TSNetwork is a framework based on ASIHTTPRequest, JSONKit and XMLReader. It is aim to simplified the developement of iOS application. 
It provides a stronger access to HTTP request and image download. 

* Access to server interface by http get or post method
* Convert the server's response data(xml or json) to NSDictionary or NSArray
* Cache the server's response data and get them when the client is offline
* Clear <null> objects in the server response which will cause crash
* Get images with url
* Cache images with both ROM and database
* Manage images in the cache
* Support the gif format image

## Requirements

TSNetwork works on any iOS version and is compatible only with non-ARC projects. It depends on the following Apple frameworks:

* Foundation.framework
* UIKit.framework
* CoreGraphics.framework

* libsqlite3.dylib
* libz.dylib
* ImageIO.framework
* SystemConfiguration.framework
* QuartzCore.framework
* CFNetwork.framework
* MobileCoreServices.framework

## How to get started

1. Add the files under 'Source' and 'Library' directories to your project, and make sure 'TSDatabase' is added as resource.
2. Add the require frameworks to your project.
3. Include TSNetwork wherever you need it with `#import "TSNetwork.h"`
4. Add the following codes in the 'AppDelegate.m" file:

```objective-c
- (void)applicationWillResignActive:(UIApplication *)application
{
    [TSDBConnection closeDatabase];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [TSDBConnection getSharedDatabase];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[TSImageStore sharedStore] didReceiveMemoryWarning];
}
```
5. When you are going to handle http request, create a class which subclass 'BaseClient' class and add the following codes into it:

```objective-c
- (BOOL)isResponseValid:(id)responseObj {
    BOOL returnValue = NO;
    if ([responseObj isKindOfClass:[NSDictionary class]]){
        if ( [[responseObj objectForKey:@"success"] intValue] == 1) {
            returnValue = YES;
        }
    }
    return returnValue;
}

- (id)getData:(id)object {
    id data = nil;
    if ([object isKindOfClass:[NSDictionary class]]) {
        data = [object objectForKey:@"data"];
    }
    return data;
}

- (int)getErrorCode:(id)object {
    int errorCode = 0;
    if ([object isKindOfClass:[NSDictionary class]]) {
        errorCode = [[object objectForKey:@"success"] intValue];
    }
    return errorCode;
}

+ (DemoClient *)clientWithTarget:(id)target action:(SEL)action {
    return [[DemoClient alloc] initWithTarget:target action:action];
}

```

6. Change "DemoClient" to the name of your class.
7. Add corresonding server interfaces in this class like:

```objective-c
- (void)getListDataWithStart:(int)start limit:(int)limit {
    NSString *urlStr = @"http://serverAddress/api";
[self setHttpRequestPostWithUrl:urlStr params:[NSDictionary dictionaryWithObjectsAndKeys:
[NSNumber numberWithInt:start],@"start",
    [NSNumber numberWithInt:limit],@"limit",
    nil]];
}
```
8. In the place where you want to access the http request, add codes like:

```objective-c
- (void)loadListData {
    if (!_clientList) {
        _clientList = [DemoClient clientWithTarget:self action:@selector(dataReceived:obj:)];
   [_clientList getListDataWithStart:0 limit:kListLimit];
    }
}

- (void)dataReceived:(DemoClient *)sender obj:(NSObject *)obj {
    _clientList = nil;
if (sender.hasError) {
    TSLog("error:%@", sender.errorMessage);
    }
    if (![obj isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSDictionary *dic = (NSDictionary *)obj;
}
```
9. When you want to download images, use TSImageView or TSImageButton and get image with "getImage:" function by passing the image url into it.
10. Make sure you add a image named "TSDefaultSmallImage" as default image in the project, or the application will crash with "Default Image not exist".

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE). 