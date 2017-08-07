//
//  CycleView.h
//  JCycleView
//
//  Created by 高永杰 on 2017/8/3.
//  Copyright © 2017年 GYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CycleView : UIView

+ (instancetype)cycleVieWithFrame:(CGRect)frame localImageArray:(NSArray *)imageArray;

+ (instancetype)cycleVieWithFrame:(CGRect)frame urlArray:(NSArray *)urlArray;

@end
