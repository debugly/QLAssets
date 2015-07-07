//
//  QLAssetsMemoryCache.m
//  HelloWorld
//
//  Created by xuqianlong on 15/6/18.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLAssetsMemoryCache.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

NSString *const QLAssetsMemoryCacheClearedCache = @"QLAssetsMemoryCacheClearedCache";

@interface QLAssetsMemoryCache ()

@property (nonatomic, strong) NSCache *memCache;

@end

@implementation QLAssetsMemoryCache

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedMemoryCache
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    return [self initNamespace:@"xql"];
}

- (instancetype)initNamespace:(NSString *)ns
{
    self = [super init];
    if (self) {
        _memCache = [[NSCache alloc]init];
        _memCache.name = [@"com.summerhanada.QLAssetMemoryCache." stringByAppendingString:ns];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)clearMemory
{
    [self.memCache removeAllObjects];
    [[NSNotificationCenter defaultCenter]postNotificationName:QLAssetsMemoryCacheClearedCache object:nil];
}

- (NSString*)makeMD5String:(NSString *)string
{
    if (string == nil) {
        return nil;
    }
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)md5String:(NSString *)string
{
    return [[self makeMD5String:string]lowercaseString];
}

- (void)cacheImage:(UIImage *)image forURL:(NSString *)key
{
    if (image) {
        key = [self md5String:key];
        [self.memCache setObject:image forKey:key cost:image.size.height * image.size.width * pow(image.scale, 2)];
    }
}

- (void)cacheImage:(UIImage *)image forKey:(NSString *)key
{
    if (image) {
        [self.memCache setObject:image forKey:key cost:image.size.height * image.size.width * pow(image.scale, 2)];
    }
}

- (UIImage *)imageFromMemoryCacheForURL:(NSString *)key
{
    return [self imageFromMemoryCacheForKey:[self md5String:key]];
}

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key
{
    if (key) {
        return [self.memCache objectForKey:key];
    }
    return nil;
}

- (void)removeImageForKey:(NSString *)key
{
    if (key) {
        [self.memCache removeObjectForKey:key];
    }
}

- (void)removeImageForURL:(NSString *)key
{
    if (key) {
        [self removeImageForKey:[self md5String:key]];
    }
}

@end
