//
//  RYLRUManager.h
//  RYHttpMangeDemo
//
//  Created by LiveiOS on 2019/1/6.
//  Copyright © 2019 LiveiOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HKLRUManager : NSObject
/**
 *  当前队列的情况
 */
@property (nonatomic, copy, readonly)NSArray *currentQueue;

+ (HKLRUManager *)shareManager;

/**
 *  添加新的结点
 *
 *  @param filename 文件名字
 */
- (void)addFileNode:(NSString *)filename;

/**
 *  调整结点位置，一般用于命中缓存时
 *
 *  @param filename 文件名字
 */
- (void)refreshIndexOfFileNode:(NSString *)filename;

/**
 *  删除最近最久未使用的缓存
 *
 *  @param time 缓存时间
 *
 *  @return 删除结点的文件名列表
 */
- (NSArray *)removeLRUFileNodeWithCacheTime:(NSTimeInterval) time;

@end

NS_ASSUME_NONNULL_END
