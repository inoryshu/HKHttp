//
//  RYMemoryCache.h
//  RYHttpMangeDemo
//
//  Created by LiveiOS on 2019/1/6.
//  Copyright © 2019 LiveiOS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *  可拓展的内存缓存策略
 */
@interface HKMemoryCache : NSObject

/**
 *  将数据写入内存
 *
 *  @param data 数据
 *  @param key  键值
 */
+ (void)writeData:(id) data forKey:(NSString *)key;

/**
 *  从内存中读取数据
 *
 *  @param key 键值
 *
 *  @return 数据
 */
+ (id)readDataWithKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
