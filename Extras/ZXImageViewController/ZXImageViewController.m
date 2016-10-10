//
// ZXImageViewController.m
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

#import "ZXImageViewController.h"

@interface ZXImageViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ZXImageViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL statusBarHiddenSaved;
@property (nonatomic, assign) BOOL navigationBarHiddenSaved;
@property (nonatomic, assign) BOOL toolbarHiddenSaved;

@property (nonatomic, strong) NSMutableDictionary *placeholders;

@end

@implementation ZXImageViewController
@synthesize dataArray = _dataArray;

static NSString * const reuseIdentifier = @"ZXImageViewCell";

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.itemSpacing = 10.f;
    }
    return self;
}

- (void)dealloc
{
//    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // Configure the frame
    CGRect frame = self.view.bounds;
    frame.size.width += self.itemSpacing;
    // Configure the layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = self.itemSpacing;
    layout.minimumInteritemSpacing = self.itemSpacing;
    layout.itemSize = self.view.bounds.size;
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, self.itemSpacing);
    // Configure the UICollectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.collectionView.allowsSelection = NO;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    // Scroll to displayed index
    self.displayedIndex = self.displayedIndex;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //
    _statusBarHiddenSaved = [UIApplication sharedApplication].statusBarHidden;
    if (self.navigationController) {
        _navigationBarHiddenSaved = self.navigationController.navigationBarHidden;
        _toolbarHiddenSaved = self.navigationController.toolbarHidden;
        _statusBarHidden = _navigationBarHiddenSaved && _toolbarHiddenSaved;
    } else {
        _navigationBarHiddenSaved = YES;
        _toolbarHiddenSaved = YES;
        _statusBarHidden = YES;
    }
    //
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        if (self.navigationController == nil) {
            [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden withAnimation:[self preferredStatusBarUpdateAnimation]];
        }
    } else if (self.navigationController) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    //
    if (self.navigationController) {
        self.view.backgroundColor = [UIColor whiteColor];
    } else {
        self.view.backgroundColor = [UIColor blackColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // restore saved status bar hidden
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHiddenSaved withAnimation:[self preferredStatusBarUpdateAnimation]];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Properties

- (NSArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (void)setDataArray:(NSArray *)dataArray {
    [dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIImage class]]) {
            [self setImage:obj];
        } else if ([obj isKindOfClass:[NSURL class]]) {
            [self setImageWithURL:obj];
        } else if ([obj isKindOfClass:[NSString class]]) {
            [self setImageWithURL:[NSURL URLWithString:obj]];
        }
    }];
}

- (void)setDisplayedIndex:(NSUInteger)displayedIndex {
    if (displayedIndex < self.dataArray.count) {
        _displayedIndex = displayedIndex;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_displayedIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

- (NSMutableDictionary *)placeholders {
    if (_placeholders == nil) {
        _placeholders = [[NSMutableDictionary alloc] init];
    }
    return _placeholders;
}

#pragma mark Set Images && URLs

- (void)setImage:(UIImage *)image {
    [self setImageWithURL:nil placeholder:image];
}

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholder:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholder:(UIImage *)image {
    if (url && image) {
        _dataArray = [[self.dataArray arrayByAddingObject:url] copy];
        [self.placeholders setObject:image forKey:url];
    } else if (url) {
        _dataArray = [[self.dataArray arrayByAddingObject:url] copy];
    } else if (image) {
        _dataArray = [[self.dataArray arrayByAddingObject:image] copy];
    }
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    // Clear contents
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZXImageView *imageView = (ZXImageView *)obj;
        [imageView removeFromSuperview];
    }];
    
    // Configure the cell
    CGRect rect = self.view.bounds;
    ZXImageView *imageView = [[ZXImageView alloc] initWithFrame:rect];
    imageView.delegate = self;
    [cell.contentView addSubview:imageView];
    //
    id obj = self.dataArray[indexPath.row];
    if ([obj isKindOfClass:[UIImage class]]) {
        imageView.image = obj;
    } else if ([obj isKindOfClass:[NSURL class]]) {
        imageView.image = self.placeholders[obj];
        imageView.imageURL = obj;
    }
    
    //
    return cell;
}

#pragma mark <ZXImageViewDelegate>

- (void)imageViewDidSingleTap:(ZXImageView *)imageView {
    if (self.navigationController) {
        if (!_statusBarHiddenSaved && !_navigationBarHiddenSaved) {
            _statusBarHidden = !_statusBarHidden;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden withAnimation:[self preferredStatusBarUpdateAnimation]];
            } else if (_statusBarHidden) { // 回调 prefersStatusBarHidden
                [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
                    [self setNeedsStatusBarAppearanceUpdate];
                }];
            }
        }
        if (!_navigationBarHiddenSaved) {
            // 回调 prefersStatusBarHidden
            [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:NO];
        }
        if (!_toolbarHiddenSaved) {
            [self.navigationController setToolbarHidden:!self.navigationController.toolbarHidden animated:NO];
        }
        // navigationBar animation
        if (!_navigationBarHiddenSaved || !_toolbarHiddenSaved) {
            CATransition *animation = [CATransition animation];
            animation.duration = UINavigationControllerHideShowBarDuration;
            animation.type = kCATransitionFade;
            [self.navigationController.view.layer addAnimation:animation forKey:nil];
        }
        // backgroundColor animation
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            self.view.backgroundColor = _statusBarHidden ? [UIColor blackColor] : [UIColor whiteColor];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imageViewDidLongPress:(ZXImageView *)imageView {
    self.actionImageView = imageView;
    if (self.actions.count > 0) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:self.actionTitle delegate:self cancelButtonTitle:self.actionCancel destructiveButtonTitle:nil otherButtonTitles:nil];
        for (ZXImageViewAction *action in self.actions) {
            [sheet addButtonWithTitle:(action.title ? action.title : @"")];
        }
        [sheet showInView:self.view];
    }
}

- (void)imageView:(ZXImageView *)imageView willShowActivityIndicatorView:(UIActivityIndicatorView *)activityIndicatorView {
    activityIndicatorView.color = _statusBarHidden ? [UIColor whiteColor] : [UIColor blackColor];
}

@end
