//
//  ZPGCDTimer.h
//  GCD定时器
//
//  Created by 赵鹏 on 2019/8/14.
//  Copyright © 2019 赵鹏. All rights reserved.
//

//本类是对GCD定时器的封装。

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZPGCDTimer : NSObject

+ (NSString *)execTask:(void(^)(void))task
           start:(NSTimeInterval)start
        interval:(NSTimeInterval)interval
         repeats:(BOOL)repeats
           async:(BOOL)async;

+ (void)cancelTask:(NSString *)task;

@end

NS_ASSUME_NONNULL_END
