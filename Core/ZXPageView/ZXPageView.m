//
// ZXPageView.m
//
// Copyright (c) 2016-2017 Zhao Xin (https://github.com/xinyzhao/ZXUtilityCode)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ZXPageView.h"

@interface ZXPageView () <NSCacheDelegate>
@property (nonatomic, strong) NSCache *pageViews;
@property (nonatomic, assign) NSTimeInterval timestamp;

- (void)initView;

- (void)resetEdgeInset;

- (NSInteger)contentPage;
- (NSInteger)correctPage:(NSInteger)page;
- (NSInteger)prevPage;
- (NSInteger)nextPage;

- (UIView *)currentView;
- (UIView *)prevView;
- (UIView *)nextView;
- (UIView *)subviewForPageAtIndex:(NSInteger)index;

- (void)autoPaging:(NSTimeInterval)delay;
- (void)nextPaging;
- (void)stopPaging;

@end

@implementation ZXPageView
@synthesize delegate = _delegate;

#pragma mark Initialization

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.direction = ZXPageViewDirectionHorizontal;
    self.pageViews = [[NSCache alloc] init];
    self.pageViews.delegate = self;
    self.pagingEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
}

- (void)dealloc
{
    [self stopPaging];
}

#pragma mark Direction

- (void)setDirection:(ZXPageViewDirection)direction {
    if (direction == ZXPageViewDirectionHorizontal) {
        _direction = ZXPageViewDirectionHorizontal;
    } else {
        _direction = ZXPageViewDirectionVertical;
    }
    [self resetEdgeInset];
    [self setNeedsLayout];
}

/**
 CGFLOAT_MAX/FLT_MAX/MAXFLOAT
 CGFLOAT_MAX 在 iOS 10.3 中指向 DBL_MAX，会导致NaN错误
 */
- (void)resetEdgeInset {
    if (_numberOfPages > 1) {
        if (_direction == ZXPageViewDirectionHorizontal) {
            CGFloat width = self.frame.size.width;
            width *= floorf(FLT_MAX / width);
            self.contentInset = UIEdgeInsetsMake(0, width, 0, width);
        } else {
            CGFloat height = self.frame.size.height;
            height *= floorf(FLT_MAX / height);
            self.contentInset = UIEdgeInsetsMake(height, 0, height, 0);
        }
    } else {
        self.contentInset = UIEdgeInsetsZero;
    }
}

#pragma mark Reload data

- (void)reloadData {
    [self.pageViews removeAllObjects];
    [self setNeedsLayout];
}

#pragma mark Page Setter

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:YES];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    CGPoint offset = CGPointZero;
    if (_direction == ZXPageViewDirectionHorizontal) {
        offset.x = currentPage * self.frame.size.width;
    } else {
        offset.y = currentPage * self.frame.size.height;
    }
    [self setContentOffset:offset animated:animated];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self resetEdgeInset];
    [self setNeedsLayout];
}

#pragma mark Page Getter

- (NSInteger)contentPage {
    NSInteger page = 0;
    if (_direction == ZXPageViewDirectionHorizontal) {
        page = roundf(self.contentOffset.x / self.frame.size.width);
    } else {
        page = roundf(self.contentOffset.y / self.frame.size.height);
    }
    return page;
}

- (NSInteger)correctPage:(NSInteger)page {
    if (page < 0) {
        page = ABS(page) % _numberOfPages;
        if (page != 0) {
            page = _numberOfPages - page;
        }
    } else if (page >= _numberOfPages) {
        page = page % _numberOfPages;
    }
    return page;
}

- (NSInteger)prevPage {
    NSInteger prevPage = _currentPage - 1;
    if (prevPage < 0 && _numberOfPages > 2) {
        prevPage = [self correctPage:prevPage];
    }
    return prevPage;
}

- (NSInteger)nextPage {
    NSInteger nextPage = _currentPage + 1;
    if (nextPage >= _numberOfPages && _numberOfPages > 2) {
        nextPage = [self correctPage:nextPage];
    }
    return nextPage;
}

#pragma mark Page View

- (UIView *)currentView {
    return [self subviewForPageAtIndex:self.currentPage];
}

- (UIView *)prevView {
    return [self subviewForPageAtIndex:self.prevPage];
}

- (UIView *)nextView {
    return [self subviewForPageAtIndex:self.nextPage];
}

- (UIView *)subviewForPageAtIndex:(NSInteger)index {
    UIView *view = [self.pageViews objectForKey:@(index)];
    if (view == nil) {
        if ([_delegate respondsToSelector:@selector(pageView:subviewForPageAtIndex:)]) {
            if (index >= 0 && index < _numberOfPages) {
                view = [_delegate pageView:self subviewForPageAtIndex:index];
            } else {
                NSInteger pageIndex = [self correctPage:index];
                view = [_delegate pageView:self subviewForPageAtIndex:pageIndex];
            }
            if (view) {
                [self.pageViews setObject:view forKey:@(index)];
                [self addSubview:view];
            }
        }
    }
    return view;
}

#pragma mark Auto paging

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval = timeInterval;
    if (_timeInterval >= 0.1) {
        [self autoPaging:_timeInterval];
    } else {
        [self stopPaging];
    }
}

- (void)autoPaging:(NSTimeInterval)delay {
    if (_numberOfPages > 1 && delay > 0.01) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(nextPaging) withObject:nil afterDelay:delay];
    }
}

- (void)nextPaging {
    if (_numberOfPages > 1) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970] - _timestamp;
        if (time > _timeInterval) {
            if (!self.isTracking && !self.isDragging && !self.isDecelerating) {
                self.currentPage = self.contentPage + 1;
            }
        }
        [self autoPaging:0.1];
    }
}

- (void)stopPaging {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    if (_numberOfPages > 0) {
        NSInteger currentPage = [self contentPage];
        //
        CGRect currentFrame = self.frame;
        if (_direction == ZXPageViewDirectionHorizontal) {
            currentFrame.origin = CGPointMake(currentPage * self.frame.size.width, 0);
        } else {
            currentFrame.origin = CGPointMake(0, currentPage * self.frame.size.height);
        }
        self.currentView.frame = currentFrame;
        //
        if (_numberOfPages > 1) {
            NSInteger prevPage = currentPage - 1;
            NSInteger nextPage = currentPage + 1;
            //
            CGRect prevFrame = self.frame;
            CGRect nextFrame = self.frame;
            //
            if (_direction == ZXPageViewDirectionHorizontal) {
                prevFrame.origin = CGPointMake(prevPage * self.frame.size.width, 0);
                nextFrame.origin = CGPointMake(nextPage * self.frame.size.width, 0);
            } else {
                prevFrame.origin = CGPointMake(0, prevPage * self.frame.size.height);
                nextFrame.origin = CGPointMake(0, nextPage * self.frame.size.height);
            }
            //
            self.prevView.frame = prevFrame;
            self.nextView.frame = nextFrame;
            //
            _timestamp = [[NSDate date] timeIntervalSince1970];
        }
    }
}

- (void)setContentOffset:(CGPoint)contentOffset {
    super.contentOffset = contentOffset;
    //
    if (_numberOfPages > 0) {
        NSInteger contentPage = [self contentPage];
        NSInteger correctPage = [self correctPage:contentPage];
        if (_currentPage != correctPage) {
            _currentPage = correctPage;
            //
            if ([_delegate respondsToSelector:@selector(pageView:willDisplaySubview:forPageAtIndex:)]) {
                [_delegate pageView:self willDisplaySubview:self.currentView forPageAtIndex:_currentPage];
            }
        }
    }
}

#pragma mark <NSCacheDelegate>

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    UIView *pageView = obj;
    [pageView removeFromSuperview];
}

@end

