//
// ZXPageView.h
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

#import <UIKit/UIKit.h>

@class ZXPageView;

/**
 ZXPageViewDelegate
 */
@protocol ZXPageViewDelegate <NSObject, UIScrollViewDelegate>
@required
/**
 Make an UIView object for page

 @param pageView The pageView
 @param index The index of page
 @return An subview for page
 */
- (UIView *)pageView:(ZXPageView *)pageView subviewForPageAtIndex:(NSInteger)index;

@optional
/**
 The subview will display

 @param pageView The pageView
 @param subview The subview
 @param index The index of page
 */
- (void)pageView:(ZXPageView *)pageView willDisplaySubview:(UIView *)subview forPageAtIndex:(NSInteger)index;

@end

/**
 Direction of scrolling
 */
typedef NS_ENUM(NSInteger, ZXPageViewDirection) {
    ZXPageViewDirectionHorizontal,
    ZXPageViewDirectionVertical,
};

/**
 Orientation of scrolling
 */
typedef NS_ENUM(NSInteger, ZXPageViewOrientation) {
    ZXPageViewOrientationEndless, // End to end, both of orientation
    ZXPageViewOrientationForward, // Left to right on horizontal, up to down on vertical
    //ZXPageViewOrientationReverse, // Right to left on horizontal, down to up on vertical, doesn't yet support
};

/**
 ZXPageView
 */
@interface ZXPageView : UIScrollView
/**
 Delegate, see ZXPageViewDelegate
 */
@property (nonatomic, weak) id <ZXPageViewDelegate> delegate;
/**
 Direction, default is ZXPageViewDirectionHorizontal
 */
@property (nonatomic, assign) ZXPageViewDirection direction;
/**
 Current page, default 0
 */
@property (nonatomic, assign) NSInteger currentPage;
/**
 The number of pages, default 0
 */
@property (nonatomic, assign) NSInteger numberOfPages;
/**
 Time interval for auto-paging, default 0 mean no auto-paging
 */
@property (nonatomic, assign) NSTimeInterval timeInterval;
/**
 Orientation, default ZXPageViewOrientationEndless
 */
@property (nonatomic, assign) ZXPageViewOrientation orientation;

/**
 Set current page with animated

 @param currentPage The current page
 @param animated animated or immediately
 */
- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

/**
 Reload data
 */
- (void)reloadData;

@end
