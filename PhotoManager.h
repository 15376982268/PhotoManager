//
//  PhotoManager.h
//  BaseProject
//
//  Created by liyanting on 17/2/7.
//  Copyright © 2017年 liyanting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

//返回值分别是：用于存储相册名字、用于相册缩略图、用于存储assets's内容：用于后面获取整
typedef void (^AlbumsBlock) (NSMutableArray *,NSMutableDictionary *,NSMutableArray *);


@interface PhotoManager : NSObject

@property(nonatomic,strong)AlbumsBlock albumBlock;

@property(nonatomic,strong)NSMutableArray * albumsInfoArray;//用于存储相册名字
@property(nonatomic,strong)NSMutableDictionary * albumSmallDic;//用于相册缩略图
@property(nonatomic,strong)NSMutableArray * assetArray;//用于存储assets's内容：用于后面获取整个相册的内容


+(id)sharePhotoManager;

#pragma mark 获取相册列表
-(void)getAlbumListRequestWith:(AlbumsBlock)infoBlock;



@end
