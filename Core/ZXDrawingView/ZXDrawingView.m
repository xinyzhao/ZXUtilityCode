//
// ZXDrawingView.m
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

#import "ZXDrawingView.h"

@interface ZXDrawingPath : UIBezierPath
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) BOOL isEraser;

@end

@implementation ZXDrawingPath

@end

@interface ZXDrawingView ()
@property (nonatomic, strong) NSMutableArray *linePaths;

@end

@implementation ZXDrawingView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

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
    self.backgroundColor = [UIColor clearColor];
    self.linePaths = [[NSMutableArray alloc] init];
    self.lineColor = [UIColor blackColor];
    self.lineWidth = 1.f;
}

#pragma mark Draw

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    for (ZXDrawingPath *path in self.linePaths) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetBlendMode(context, path.isEraser ? kCGBlendModeDestinationIn : kCGBlendModeNormal);
        CGContextSetLineWidth(context, path.lineWidth);
        [path.lineColor setStroke];
        CGContextAddPath(context, path.CGPath);
        CGContextDrawPath(context, kCGPathStroke);
    }
}

#pragma mark Functions

- (void)clear {
    if (self.linePaths.count > 0) {
        [self.linePaths removeAllObjects];
        [self setNeedsDisplay];
    }
}

- (void)undo {
    if (self.linePaths.count > 0) {
        [self.linePaths removeLastObject];
        [self setNeedsDisplay];
    }
}

#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    //
    ZXDrawingPath *path = [ZXDrawingPath bezierPath];
    path.isEraser = _eraserEnabled;
    if (path.isEraser) {
        path.lineColor = [UIColor clearColor];
    } else {
        path.lineColor = self.lineColor;
    }
    path.lineWidth = self.lineWidth;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    [path moveToPoint:point];
    [self.linePaths addObject:path];
    //
    if (_touchesBegan) {
        _touchesBegan(touches, event);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    //
    ZXDrawingPath *path = [self.linePaths lastObject];
    [path addLineToPoint:point];
    [self setNeedsDisplay];
    //
    if (_touchesMoved) {
        _touchesMoved(touches, event);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
    //
    if (_touchesEnded) {
        _touchesEnded(touches, event);
    }
}

@end
