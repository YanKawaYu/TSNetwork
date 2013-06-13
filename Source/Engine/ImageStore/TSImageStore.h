//
//  ImageStore.h
//  TSNetwork
//
//  Created by zhaoxy on 11-11-20.
//  Copyright (c) 2013年 Tsinghua. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSImageStoreDelegate <NSObject>

- (void)imageDownloadDidSucceed:(id)image;
- (void)imageDownloadDidFail;

@end

@interface TSImageStore : NSObject{
    NSMutableDictionary *cacheImages;
    NSMutableDictionary *delegates;
    NSMutableDictionary *pending;
    NSMutableArray      *badUrls;
}

//设置图片下载队列的最大长度，默认为10
@property (nonatomic, assign) int maxConnection;
//设置下载图片的超时时间，默认为5秒
@property (nonatomic, assign) int timeOutSeconds;

//单实例
+(TSImageStore *)sharedStore;
//根据url获取图片
- (id)getProfileImage:(NSString*)url delegate:(id)delegate;
//根据url移出所有委托
- (void)removeDelegate:(id)delegate forURL:(NSString*)key;
//根据url清除该图片的缓存
- (void)releaseImage:(NSString*)url;
//操作系统提示内存警告时调用
- (void)didReceiveMemoryWarning;
//设置图片是否可被删除（由于数据库中的图片会定期被删除）
- (void)setImageCanDelete:(BOOL)canDelete forURL:(NSString *)url;

@end
