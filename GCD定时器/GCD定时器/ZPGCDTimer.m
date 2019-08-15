//
//  ZPGCDTimer.m
//  GCD定时器
//
//  Created by 赵鹏 on 2019/8/14.
//  Copyright © 2019 赵鹏. All rights reserved.
//

#import "ZPGCDTimer.h"

@implementation ZPGCDTimer

static NSMutableDictionary *timers;  //用来存储定时器和它的唯一标识符的容器。
dispatch_semaphore_t semaphore;  //信号量

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers = [NSMutableDictionary dictionary];
        
        //因为在下面的执行任务的方法中会给定时器字典添加元素，而下面的取消任务的方法中又会在定时器字典中删除元素。因为不能同时操作一个可变字典，所以下面的两个方法在同一时刻只能执行一个，所以用信号量的方式来进行线程同步。
        semaphore = dispatch_semaphore_create(1);
    });
}

+ (NSString *)execTask:(void (^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async
{
    //如果传进来的任务block没有值或者开始时间小于0或者间隔时间小于等于0的话则直接返回，就不执行下面的代码了。
    if (!task || start < 0 || (interval <= 0 && repeats))
    {
        return nil;
    }
    
    /**
     1、创建队列：
     先判断是否需要异步，如果需要的话，则获取全局的并发队列，以后的定时器任务会在新线程中执行。如果不需要的话则获取主队列，以后的定时器任务会在主线程中执行。
     */
    dispatch_queue_t queue  = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    
    /**
     2、创建定时器：
     下面方法中的最后一个参数是指之后定时器执行的回调函数（任务）要放在哪个队列中。
     */
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    /**
     3、设置时间：
     下面函数的意思是，从现在开始，2秒后开始执行任务，然后每隔1秒时间执行一次任务。
     */
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    
    /********信号量*******/
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //设置定时器的唯一标识：
    static int i = 0;
    NSString *name = [NSString stringWithFormat:@"%d", i++];
    
    //把定时器存储到可变字典中
    [timers setObject:timer forKey:name];
    
    dispatch_semaphore_signal(semaphore);
    /********信号量*******/
    
    //4、设置回调函数（任务）：
    dispatch_source_set_event_handler(timer, ^{
        task();
        
        if (!repeats)
        {
            //如果不需要重复的话则取消定时器
            [self cancelTask:name];
        }
    });
    
    //5、启动定时器：
    dispatch_resume(timer);
    
    
    
    return name;
}

+ (void)cancelTask:(NSString *)name
{
    if (name.length == 0)
    {
        return;
    }
    
    /********信号量*******/
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //根据唯一标识来取出对应的定时器
    dispatch_source_t timer = [timers objectForKey:name];
    
    if (timer)
    {
        //取消定时器
        dispatch_source_cancel(timer);
        
        [timers removeObjectForKey:name];
    }
    
    dispatch_semaphore_signal(semaphore);
    /********信号量*******/
}

@end
