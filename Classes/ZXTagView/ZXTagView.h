//
// ZXTagView.h
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

/// ZXTagAction
typedef void(^ZXTagAction)(NSString *tag, NSUInteger index);

/// ZXTagLabel
@interface ZXTagLabel : UILabel
@property (nonatomic, copy) ZXTagAction action;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, readonly) CGSize contentSize;

- (instancetype)initWithText:(NSString *)text;

@end

/// ZXTagOption
typedef void(^ZXTagOption)(ZXTagLabel *label);

/// ZXTagView
@interface ZXTagView : UIView
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) UIEdgeInsets paddingInset;
@property (nonatomic, readonly) CGFloat contentHeight;

- (void)addTag:(NSString *)tag option:(ZXTagOption)option action:(ZXTagAction)action;
- (void)insertTag:(NSString *)tag atIndex:(NSUInteger)index option:(ZXTagOption)option action:(ZXTagAction)action;

- (NSString *)tagAtIndex:(NSUInteger)index;
- (ZXTagLabel *)tagLabelAtIndex:(NSUInteger)index;

- (void)removeTag:(NSString *)tag;
- (void)removeTagAtIndex:(NSUInteger)index;
- (void)removeAllTags;

@end
