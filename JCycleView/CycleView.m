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

@interface CycleView () <UIScrollViewDelegate>

//滚动视图 用于放五个imageview
@property (nonatomic, strong) UIScrollView   * scrollView;

//存放image对象
@property (nonatomic, strong) NSMutableArray * imageData;

@property (nonatomic, strong) UIPageControl  * pageControl;

//计时器
@property (nonatomic, weak) NSTimer          * timer;

/**
 *当前索引
 */
@property (nonatomic, assign) NSInteger        currentIndex;

@end


@implementation CycleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initialization];
        
        [self addSubview:self.scrollView];

        [self addSubview:self.pageControl];
        
        _currentIndex = 0;
        
        [self setupTimer];

    }
    return self;
}
/** 设置默认参数 */
- (void)initialization
{
    _scrollTimeInterval = 5;
}

- (void)setScrollTimeInterval:(CGFloat)scrollTimeInterval
{
    _scrollTimeInterval = scrollTimeInterval;
    [self setupTimer];
}
- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    _placeholderImage = placeholderImage;
    
    
}

- (void)makeupScrollView
{
    NSInteger n = 0;
    for (NSInteger index = -2; index < 3; index ++)
    {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:(CGRect){n * ThisViewWidth, 0, ThisViewWidth, ThisViewHeight}];
        n ++;
        imageView.image = _imageData[[self returnImage:index]];//[self returnImage:index];
        NSLog(@"tag ========== %ld",[self returnImage:index]);
        imageView.tag = [self returnImage:index];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
        [imageView addGestureRecognizer:tap];
        [self.scrollView addSubview:imageView];
        
    }
    _pageControl.numberOfPages = _imageData.count;
}

- (void)clickImage
{
    if (self.clickItemBlock)
    {
        self.clickItemBlock(_currentIndex);
    }
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

+ (instancetype)cycleVieWithFrame:(CGRect)frame localImageArray:(NSArray *)imageArray placeholderImage:(UIImage *)placeholderImage
{
    CycleView *cycle = [[CycleView alloc] initWithFrame:frame];
    cycle.imageData = [NSMutableArray arrayWithCapacity:imageArray.count];
    cycle.placeholderImage = placeholderImage;
    [imageArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:@"http"])
        {
            [cycle.imageData addObject:cycle.placeholderImage];
//            [cycle.imageData addObject:[UIImage imageNamed:@"placeholder"]];
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
                UIImage * img = [cycle downloadImageWithStr:obj];
                cycle.imageData[idx] = img;
                if (!img)
                {
                    NSLog(@"图片为空");
                }
                
                if (img)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%ld---------%@", idx, img);
                        
                        for (UIImageView *imgView in cycle.scrollView.subviews)
                        {
                            if (imgView.tag == idx)
                            {
                                imgView.image = img;
                            }
                        }
                    });
                }
            }
        }];
    });

    return cycle;
}
//下载图片
- (UIImage *)downloadImageWithStr:(NSString *)str
{
    NSURL * url = [NSURL URLWithString:str];
    NSError * error = nil;
    NSData * data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    UIImage * img = [UIImage imageWithData:data];

    if (img)
    {
        return img;
    }
    return [UIImage imageNamed:@"placeholder"];
}

- (void)setupTimer
{
    [self invalidateTimer];
    NSTimer *timer = [NSTimer timerWithTimeInterval:_scrollTimeInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        [_scrollView setContentOffset:CGPointMake(self.frame.size.width * 3, 0) animated:YES];
    }];
    _timer = timer;
//    NSDefaultRunLoopMode  模式在滑动scrollView的时候会暂停计时器
//    UITrackingRunLoopMode  NSRunLoopCommonModes 不会暂停计时器
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self invalidateTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self setupTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.itemDidScrollBlock)
    {
        self.itemDidScrollBlock(_currentIndex);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x >= (ThisViewWidth * 3) || scrollView.contentOffset.x <= ThisViewWidth)
    {
        if (scrollView.contentOffset.x >= (ThisViewWidth * 3))
        {
            _currentIndex++;
            NSArray * arr = scrollView.subviews;
            UIImageView *imageView0 = arr[0];
            UIImageView *imageView1 = arr[1];
            UIImageView *imageView2 = arr[2];
            UIImageView *imageView3 = arr[3];
            UIImageView *imageView4 = arr[4];
            
            imageView0.image = imageView1.image;
            imageView0.tag = imageView1.tag;
            
            imageView1.image = imageView2.image;
            imageView1.tag = imageView2.tag;
            
            imageView2.image = imageView3.image;
            imageView2.tag = imageView3.tag;
            
            imageView3.image = imageView4.image;
            imageView3.tag = imageView4.tag;

            if (_currentIndex >= _imageData.count)
            {
                _currentIndex = 0;
            }
            
            NSInteger ind = _currentIndex + 2;
            
            if (ind >= _imageData.count)
            {
                ind = ind - _imageData.count;
            }
            
            imageView4.image = _imageData[ind];
            imageView4.tag = ind;

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
            imageView4.tag = imageView3.tag;
            
            imageView3.image = imageView2.image;
            imageView3.tag = imageView2.tag;
            
            imageView2.image = imageView1.image;
            imageView2.tag = imageView1.tag;
            
            imageView1.image = imageView0.image;
            imageView1.tag = imageView0.tag;
            
            _currentIndex --;
            
            if (_currentIndex < 0)
            {
                _currentIndex = _imageData.count - 1;
            }
            
            NSInteger ind = _currentIndex - 2;
            
            if (ind < 0)
            {
                ind = ind + _imageData.count;
            }
            imageView0.image = _imageData[ind];
            imageView0.tag = ind;
        }
        
        _pageControl.currentPage = _currentIndex;
        
        [scrollView setContentOffset:CGPointMake(ThisViewWidth * 2, 0)];
        
//        NSLog(@"%ld",(long)_pageControl.currentPage);
        
    }
}

@end

