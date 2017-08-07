//
//  CycleView.m
//  JCycleView
//
//  Created by 高永杰 on 2017/8/3.
//  Copyright © 2017年 GYJ. All rights reserved.
//

#import "CycleView.h"
#import "UIImageView+WebCache.h"
#define ThisViewWidth      (self.bounds.size.width)
#define ThisViewHeight     (self.bounds.size.height)

#define ScreenWidth         ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight        ([UIScreen mainScreen].bounds.size.height)
@interface CycleView () <UIScrollViewDelegate>
//滚动视图上放5个imageView
@property (nonatomic, strong) UIScrollView   * scrollView;

@property (nonatomic, strong) NSMutableArray        * imageData;

@property (nonatomic, strong) UIPageControl  * pageControl;

@property (nonatomic, strong) NSTimer        * timer;

@property (nonatomic, assign) NSInteger        centreViewIndex;

@end


@implementation CycleView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubview:self.scrollView];

        [self addSubview:self.pageControl];
        _centreViewIndex = 0;
//        [self makeupScrollView];
        _timer = [NSTimer timerWithTimeInterval:3 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [_scrollView setContentOffset:CGPointMake(self.frame.size.width * 3, 0) animated:YES];
        }];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}
- (void)clickBtn
{
//    [_timer  setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
}


- (void)makeupScrollView
{
    NSInteger n = 0;
    for (NSInteger index = -2; index < 3; index ++)
    {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:(CGRect){n * ThisViewWidth, 0, ThisViewWidth, ThisViewHeight}];
        n ++;
        imageView.image = _imageData[[self returnImage:index]];//[self returnImage:index];
        
        [self.scrollView addSubview:imageView];
        
    }
    _pageControl.numberOfPages = _imageData.count;
}
//根据输入的位置，返回取数组的下标
// -2 -1 0 1 2
- (NSInteger)returnImage:(NSInteger)imageViewLocation
{
    NSInteger index = _imageData.count + imageViewLocation;
    
    if (imageViewLocation >= 0)
    {
        index = imageViewLocation * 1;
    }
    
    if (index >= _imageData.count)
    {
        index -= 2;
    }
    return index;//[UIImage imageNamed:_imageData[]];
}

- (UIPageControl *)pageControl
{
    if (!_pageControl)
    {
        UIPageControl * pageControl = [[UIPageControl alloc] initWithFrame:(CGRect){0, ThisViewHeight - 30, ThisViewWidth, 30}];
        pageControl.currentPage = 0;
        pageControl.hidesForSinglePage = YES;
        pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        self.pageControl = pageControl;
    }
    return _pageControl;
}


- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        UIScrollView * tempScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        tempScrollView.backgroundColor = [UIColor lightGrayColor];
        tempScrollView.contentSize = (CGSize){ThisViewWidth * 5, ThisViewHeight};
        tempScrollView.contentOffset = CGPointMake(ThisViewWidth * 2, 0);
        tempScrollView.pagingEnabled = YES;
        tempScrollView.delegate = self;
        tempScrollView.showsHorizontalScrollIndicator = NO;
        tempScrollView.showsVerticalScrollIndicator = NO;
        self.scrollView = tempScrollView;
    }
    return _scrollView;
}
+ (instancetype)cycleVieWithFrame:(CGRect)frame urlArray:(NSArray *)urlArray
{
    CycleView *cycle = [[CycleView alloc] initWithFrame:frame];
    cycle.imageData = [NSMutableArray arrayWithCapacity:urlArray.count];
    [urlArray enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSURL * url = [NSURL URLWithString:[obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
    }];
    
    [cycle makeupScrollView];

    return cycle;
}

+ (instancetype)cycleVieWithFrame:(CGRect)frame localImageArray:(NSArray *)imageArray
{
    CycleView *cycle = [[CycleView alloc] initWithFrame:frame];
    cycle.imageData = [NSMutableArray arrayWithCapacity:imageArray.count];
    
    [imageArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:@"http"])
        {
            [cycle.imageData addObject:[UIImage imageNamed:@"placeholder"]];
        }
        else
        {
            [cycle.imageData addObject:[UIImage imageNamed:obj]];
        }
    }];

    [cycle makeupScrollView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) , ^{
        [imageArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj hasPrefix:@"http"])
            {
                UIImage * img = [cycle imageWithStr:obj];
            
                if ( img)//idx == 0 &&
                {

                    dispatch_async(dispatch_get_main_queue(), ^{
//                        imgView.image = [cycle imageWithStr:obj];
                        NSLog(@"---------%d",img);
                        cycle.imageData[idx] = img;
                        if (idx == 0)
                        {
                            UIImageView *imgView = cycle.scrollView.subviews[2];
                            imgView.image = img;
                        }
                        else if (idx == 1)
                        {
                            UIImageView *imgView = cycle.scrollView.subviews[3];
                            imgView.image = img;
                        }
                        else if (idx == 2)
                        {
                            UIImageView *imgView = cycle.scrollView.subviews[4];
                            imgView.image = img;
                        }
                    });
                    
                }
            }
        }];
    });

    return cycle;
}
- (UIImage *)imageWithStr:(NSString *)str
{
    
    NSURL * url = [NSURL URLWithString:str];
    NSData * data = [NSData dataWithContentsOfURL:url];
    UIImage * img = [UIImage imageWithData:data];
    
//    UIImage *theImage = NULL;
//    NSString *imageFileName = [BT_strings getFileNameFromURL:theURL];
//    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:theURL]];
//    theImage = [[UIImage alloc] initWithData:imageData];
//    [BT_fileManager saveImageToFile:theImage fileName:imageFileName];
//    return theImage;
    if (img)
    {
        return img;
    }
    return [UIImage imageNamed:@"placeholder"];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x >= (ThisViewWidth * 3) || scrollView.contentOffset.x <= ThisViewWidth)
    {
        if (scrollView.contentOffset.x >= (ThisViewWidth * 3))
        {
            _centreViewIndex++;
            NSArray * arr = scrollView.subviews;
            UIImageView *imageView0 = arr[0];
            UIImageView *imageView1 = arr[1];
            UIImageView *imageView2 = arr[2];
            UIImageView *imageView3 = arr[3];
            UIImageView *imageView4 = arr[4];
            
            imageView0.image = imageView1.image;
            imageView1.image = imageView2.image;
            imageView2.image = imageView3.image;
            imageView3.image = imageView4.image;

            if (_centreViewIndex >= _imageData.count)
            {
                _centreViewIndex = 0;
            }
            
            NSInteger ind = _centreViewIndex + 2;
            
            if (ind >= _imageData.count)
            {
                ind = ind - _imageData.count;
            }
            
            imageView4.image = _imageData[ind];

        }
        else if(scrollView.contentOffset.x <= ThisViewWidth)
        {
            NSArray * arr = scrollView.subviews;
            UIImageView *imageView0 = arr[0];
            UIImageView *imageView1 = arr[1];
            UIImageView *imageView2 = arr[2];
            UIImageView *imageView3 = arr[3];
            UIImageView *imageView4 = arr[4];
            
            imageView4.image = imageView3.image;
            imageView3.image = imageView2.image;
            imageView2.image = imageView1.image;
            imageView1.image = imageView0.image;
            
            _centreViewIndex --;
            
            if (_centreViewIndex < 0)
            {
                _centreViewIndex = _imageData.count - 1;
            }
            
            NSInteger ind = _centreViewIndex - 2;
            
            if (ind < 0)
            {
                ind = ind + _imageData.count;
            }
            imageView0.image = _imageData[ind];
        }
        
        _pageControl.currentPage = _centreViewIndex;
        
        [scrollView setContentOffset:CGPointMake(ThisViewWidth * 2, 0)];
        
//        NSLog(@"%ld",(long)_pageControl.currentPage);
        
    }
}

@end

