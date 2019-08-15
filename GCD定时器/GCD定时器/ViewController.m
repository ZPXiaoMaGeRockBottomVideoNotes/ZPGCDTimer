//
//  ViewController.m
//  GCD定时器
//
//  Created by 赵鹏 on 2019/8/14.
//  Copyright © 2019 赵鹏. All rights reserved.
//

/**
 CADisplayLink和NSTimer都是依赖于RunLoop的，如果RunLoop的任务过于繁重，可能会导致CADisplayLink和NSTimer不准时；
 GCD的定时器是直接和系统内核挂钩的，是不依赖于RunLoop的，所以会更加准时；
 当使用的是GCD定时器的时候，拖拽UIScrollView控件，不会影响定时器的运行。这是因为当拖拽UIScrollView控件的时候改变的是RunLoop的Mode，而GCD定时器与RunLoop无关，所以不会影响定时器的正常运行。
 */
#import "ViewController.h"
#import "ZPGCDTimer.h"

@interface ViewController ()

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, copy) NSString *task;

@end

@implementation ViewController

#pragma mark ————— 生命周期 —————
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.task = [ZPGCDTimer execTask:^{
        NSLog(@"执行任务 - %@", [NSThread currentThread]);
    } start:2.0 interval:1.0 repeats:YES async:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [ZPGCDTimer cancelTask:self.task];
}

@end
