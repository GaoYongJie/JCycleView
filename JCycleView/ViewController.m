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
                       @"http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"
                       ];//, , @"h2.jpg", @"h3.jpg", @"h4.jpg"
    CycleView * cycle = [CycleView cycleVieWithFrame:(CGRect){0, 20, self.view.bounds.size.width, 200} localImageArray:array];
    [self.view addSubview:cycle];
    
    
//    //http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg
//    NSArray *array1 = @[@"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
//                        @"https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg"];
//    CycleView * cycle1 = [CycleView cycleVieWithFrame:(CGRect){0, 260, self.view.bounds.size.width, 200} urlArray:array1];
//    [self.view addSubview:cycle1];
    

    
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 500, 300, 200)];
//    imgView.image = [UIImage imageNamed:@"placeholder"];
//    //异步
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        NSURL * url = [NSURL URLWithString:@"http://cc.cocimg.com/api/uploads/170731/aa494b735ac99e284e8699f1b0898ad3.png"];
//        NSData * data = [NSData dataWithContentsOfURL:url];
//        UIImage * img = [UIImage imageWithData:data];
//        if (img)
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                imgView.image = img;
//            });
//        }
//    });
//    [self.view addSubview:imgView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
