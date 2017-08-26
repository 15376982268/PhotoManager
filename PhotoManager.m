//
//  PhotoManager.m
//  BaseProject
//
//  Created by liyanting on 17/2/7.
//  Copyright © 2017年 liyanting. All rights reserved.
//

#import "PhotoManager.h"
#import "CamerAuthorizationTool.h"//获取摄像头权限

static PhotoManager * photoManager;

@interface PhotoManager()


@end

@implementation PhotoManager

+(id)sharePhotoManager{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        photoManager = [[PhotoManager alloc]init];

    });

    return photoManager;
}
#pragma mark 获取相册列表
-(void)getAlbumListRequestWith:(AlbumsBlock)infoBlock{

    //判断是否有权限获取相册
    CamerAuthorizationTool * authorizeTool = [[CamerAuthorizationTool alloc]init];
    [authorizeTool getPhotoAuthorizaionBlockWithReturnBlock:^{
        
        self.albumBlock = infoBlock;
        
        //获取相册
        [self getAlbumListDetailRequestWith:infoBlock];


        
    } WithErrorBlock:^(NSString *errorCode) {
        
        [Alert showWithTitle:errorCode];

    }];
    
   

}

-(void)getAlbumListDetailRequestWith:(AlbumsBlock)infoBlock{

    
    self.albumsInfoArray = [NSMutableArray arrayWithCapacity:0];
    self.albumSmallDic = [NSMutableDictionary dictionaryWithCapacity:0];
    self.assetArray = [NSMutableArray arrayWithCapacity:0];
    
    //按资源的创建时间排序
    PHFetchOptions * options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]]; //其中：key是PHAsset类的属性   这是一个kvc

    
    //所有照片
    PHFetchResult * cameraAssets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];//（注意不能在胶卷中获取图片，因为胶卷中的图片包含了video的显示图）要这样获取

    [self.albumsInfoArray addObject:@"相册"];
    [self.assetArray addObject:cameraAssets];
    [self getWithAsset:cameraAssets];//获取相册第一张图的缩略图
    
    DebugLog(@"相册名:相机胶卷，有%ld张图片",cameraAssets.count);
    
    
    // 获取用户自定义的相册
    PHFetchResult *customCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (PHAssetCollection *collection in customCollections) {
        
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
        [self.albumsInfoArray addObject:collection.localizedTitle];
        [self.assetArray addObject:assets];
        [self getWithAsset:assets];//获取相册第一张图的缩略图

        DebugLog(@"!!相册名:%@，有%ld张图片",collection.localizedTitle,assets.count);

        
    }
    
    if (self.albumBlock) {
        
        self.albumBlock(self.albumsInfoArray,self.albumSmallDic,self.assetArray);
    }
    
    
}
#pragma mark 获取相册的缩略图
-(void)getWithAsset:(PHFetchResult *)assets{

    /*resizeMode： 压缩模式
     PHImageRequestOptionsResizeModeNone = 0,不压缩
     PHImageRequestOptionsResizeModeFast,高效率请求,但是返回的图片尺寸可能和要求的尺寸不同
     PHImageRequestOptionsResizeModeExact,按照精准尺寸返回
     */
    
    /*deliveryMode：
     PHImageRequestOptionsDeliveryModeOpportunistic = 0,图片获取速度和质量的平衡
     PHImageRequestOptionsDeliveryModeHighQualityFormat = 1,高质量图片,
     PHImageRequestOptionsDeliveryModeFastFormat = 2 快速得到图片的情况下保证质量
     */

    if ([assets firstObject]) {//如果有照片
        
        PHImageRequestOptions *opts = [[PHImageRequestOptions alloc] init]; // assets的配置设置
        opts.synchronous = YES;//同步 or 异步
        opts.resizeMode = PHImageRequestOptionsResizeModeFast;//压缩模式 ：高效率请求,但是返回的图片尺寸可能和要求的尺寸不同
        opts.deliveryMode  = PHImageRequestOptionsDeliveryModeFastFormat;//快速得到图片的情况下保证质量

        
        [[PHImageManager defaultManager] requestImageForAsset:[assets firstObject] targetSize:CGSizeZero contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {

            DebugLog(@"获取第一张照片");
            [self.albumSmallDic setObject:result forKey:assets];

        }];

    }
  

}

@end
