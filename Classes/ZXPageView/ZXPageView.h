//
// ZXPageView.h
//
// Copyright (c) 2016 Zhao Xin. All rights reserved.
//
// https://github.com/xinyzhao/ZXUtilityCode
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

@protocol ZXPageViewDelegate <NSObject, UIScrollViewDelegate>
@required
- (UIView *)pageView:(ZXPageView *)pageView subviewForPageAtIndex:(NSInteger)index;
@optional
- (void)pageView:(ZXPageView *)pageView willDisplaySubview:(UIView *)subview forPageAtIndex:(NSInteger)index;
@end

typedef NS_ENUM(NSInteger, ZXPageViewDirection) {
    ZXPageViewDirectionHorizontal,
    ZXPageViewDirectionVertical,
};

@interface ZXPageView : UIScrollView
@property (nonatomic, weak) id <ZXPageViewDelegate> delegate;
@property (nonatomic, assign) ZXPageViewDirection direction; // Default is ZXPageViewDirectionHorizontal
@property (nonatomic, assign) NSInteger currentPage; // Default 0
@property (nonatomic, assign) NSInteger numberOfPages; // Default 0
@property (nonatomic, assign) NSTimeInterval timeInterval; // Default 0, no auto paging, least 0.1 sec.

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

- (void)reloadData;

@end