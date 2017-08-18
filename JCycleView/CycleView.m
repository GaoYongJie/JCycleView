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

/** 滚动视图 用于放五个imageview */
@property (nonatomic, strong) UIScrollView   * scrollView;




@property (nonatomic, strong) UIPageControl  * pageControl;

/** 计时器 */
@property (nonatomic, weak) NSTimer          * timer;

/** 当前索引 */
@property (nonatomic, assign) NSInteger        currentIndex;

/** 存放image对象 */
@property (nonatomic, strong) NSMutableArray * imageData;

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
    }
    return self;
}
/** 设置默认参数 */
- (void)initialization
{
    _scrollTimeInterval = 3;
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
//初始化scrollView
- (void)makeupScrollView
{
    NSInteger n = 0;
    for (NSInteger index = -2; index < 3; index ++)
    {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:(CGRect){n * ThisViewWidth, 0, ThisViewWidth, ThisViewHeight}];
        imageView.backgroundColor = [UIColor whiteColor];
        n ++;
//        imageView.image = _imageData[[self returnImage:index]];//[self returnImage:index];
        imageView.image = [self imageDataAtIndex:[self returnImage:index]];
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
    
    if (_imageData.count == 1)
    {
        return 0;
    }
    
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
        pageControl.userInteractionEnabled = NO;
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
        tempScrollView.clipsToBounds = YES;
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

+ (instancetype)cycleVieWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray placeholderImage:(UIImage *)placeholderImage
{
    CycleView *cycle = [[CycleView alloc] initWithFrame:frame];
    cycle.imageData = [NSMutableArray arrayWithCapacity:imageArray.count];
    //设置占位图
    placeholderImage ? (cycle.placeholderImage = placeholderImage) : (cycle.placeholderImage = UIImage.new);
    
    //初始化图片
    [imageArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj hasPrefix:@"http"])
        {
            //如果是需要下载的图片，则先添加占位图
            [cycle.imageData addObject:cycle.placeholderImage];
        }
        else
        {
            //直接将加入到数组中
            [cycle.imageData addObject:[UIImage imageNamed:obj]];
        }
    }];
    
    
    
    //初始化scrollView
    [cycle makeupScrollView];
    
    [cycle setupImageWithArray:imageArray];
    
    [cycle setupTimer];
    
    return cycle;
}
- (void)setupImageWithArray:(NSArray *)imageArray
{
    //异步下载图片
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) , ^{
        [imageArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj hasPrefix:@"http"])
            {
                UIImage * img = [self downloadImageWithStr:obj];
                
                if (img)
                {
                    _imageData[idx] = img;
                    NSLog(@"下载完成 %ld",idx);
                    //如果下载的图片正好要显示就回到主线程显示
                    for (UIImageView *imgView in _scrollView.subviews)
                    {
                        if (imgView.tag == idx)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                imgView.image = img;
                            });
                        }
                    }
                }
            }
        }];
    });
    
}
//下载图片
- (UIImage *)downloadImageWithStr:(NSString *)str
{
    NSError * error = nil;
    NSData  * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:str] options:0 error:&error];
    UIImage * img = [UIImage imageWithData:data];
    return img ? img : _placeholderImage;
}
//初始化定时器
- (void)setupTimer
{
    if (_imageData.count < 2)
    {
        return;
    }
    [self invalidateTimer];
    NSTimer *timer = [NSTimer timerWithTimeInterval:_scrollTimeInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        [_scrollView setContentOffset:CGPointMake(self.frame.size.width * 3, 0) animated:YES];
    }];
    _timer = timer;
//    NSDefaultRunLoopMode  模式在滑动scrollView的时候会暂停计时器
//    UITrackingRunLoopMode  NSRunLoopCommonModes 不会暂停计时器
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
//销毁定时器
- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self invalidateTimer];
}

#pragma mark - Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x >= (ThisViewWidth * 3) || scrollView.contentOffset.x <= ThisViewWidth)
    {
        if (scrollView.contentOffset.x >= (ThisViewWidth * 3))
        {
            _currentIndex ++;
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
            //            imageView4.image = _imageData[ind];
            imageView4.image = [self imageDataAtIndex:ind];  //_imageData[ind];
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
            //            imageView0.image = _imageData[ind];
            imageView0.image = [self imageDataAtIndex:ind];
            imageView0.tag = ind;
        }
        
        _pageControl.currentPage = _currentIndex;
        
        //显示中间一个视图
        [scrollView setContentOffset:CGPointMake(ThisViewWidth * 2, 0)];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self setupTimer];
}
//将要减速
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
}
//结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //防止滑动时卡屏
    if (scrollView.contentOffset.x > ThisViewWidth * 2 && scrollView.contentOffset.x < ThisViewWidth * 3)
    {
        [scrollView setContentOffset:CGPointMake(ThisViewWidth * 3, 0) animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.itemDidScrollBlock)
    {
        self.itemDidScrollBlock(_currentIndex);
    }
}


- (UIImage *)imageDataAtIndex:(NSUInteger)index
{
    if (_imageData.count == 0)
    {
        return _placeholderImage ? _placeholderImage : UIImage.new;
    }
    return index >= _imageData.count ? _imageData[0] : _imageData[index];
}
@end

