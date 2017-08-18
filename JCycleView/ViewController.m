//
//  ViewController.m
//  JCycleView
//
//  Created by 高永杰 on 2017/8/3.
//  Copyright © 2017年 GYJ. All rights reserved.
//

#import "ViewController.h"
#import "CycleView.h"

@interface ViewController ()

@property (nonatomic, weak) CycleView * cycle;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSArray *array = @[
//                       @"1",
//                       @"h1.jpg",
                       @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
                       @"http://cc.cocimg.com/api/uploads/170804/59650af26689fe74bcc83bf211c9355f.png",
                       @"http://cc.cocimg.com/api/uploads/170731/aa494b735ac99e284e8699f1b0898ad3.png",
                       @"https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
                       @"http://cc.cocimg.com/api/uploads/170804/59650af26689fe74bcc83bf211c9355f.png",
                       @"http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg",
                       @"h2.jpg"
                       ];//, , @"h2.jpg", @"h3.jpg", @"h4.jpg"
    self.cycle = [CycleView cycleVieWithFrame:(CGRect){0, 20, self.view.bounds.size.width, 200} imageArray:array placeholderImage:[UIImage imageNamed:@"placeholder"]];
    _cycle.placeholderImage = [UIImage imageNamed:@""];
    _cycle.clickItemBlock = ^(NSInteger currentIndex) {
        NSLog(@"clickIndex = %ld",currentIndex);
    };
    _cycle.itemDidScrollBlock = ^(NSInteger currentIndex) {
        NSLog(@"currentIndex  = %ld",currentIndex);
    };
//    cycle.scrollTimeInterval = 1;
    [self.view addSubview:_cycle];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 300, 50, 50)];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
}

- (void)click
{
    CycleView *p = [[CycleView alloc] init];
    p.placeholderImage = [UIImage new];
    p = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
