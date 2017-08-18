//
//  CycleView.h
//  JCycleView
//
//  Created by 高永杰 on 2017/8/3.
//  Copyright © 2017年 GYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CycleView : UIView

/** block方式监听点击 */
@property (nonatomic, copy) void (^clickItemBlock)(NSInteger currentIndex);

/** block方式监听滚动 */
@property (nonatomic, copy) void (^itemDidScrollBlock)(NSInteger currentIndex);

/** 滚动时间间隔 */
@property (nonatomic, assign) CGFloat scrollTimeInterval;

/** 占位图 */
@property (nonatomic, strong) UIImage * placeholderImage;

/** 数组中可同时传入 本地图片名称 和 图片url */
+ (instancetype)cycleVieWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray placeholderImage:(UIImage *)placeholderImage;

@end
