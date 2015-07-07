//
//  QLAssetsMemoryCache.h
//  HelloWorld
//
//  Created by xuqianlong on 15/6/18.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const QLAssetsMemoryCacheClearedCache;

@interface QLAssetsMemoryCache : NSObject

+ (instancetype)sharedMemoryCache;

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;

- (void)cacheImage:(UIImage *)image forURL:(NSString *)key;
- (UIImage *)imageFromMemoryCacheForURL:(NSString *)key;

- (void)removeImageForKey:(NSString *)key;
- (void)removeImageForURL:(NSString *)key;

- (void)clearMemory;

@end
