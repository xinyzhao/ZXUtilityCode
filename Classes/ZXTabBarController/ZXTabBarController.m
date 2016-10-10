//
// ZXTabBarController.m
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

#import "ZXTabBarController.h"

@interface ZXTabBarController ()

@end

@implementation ZXTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // view controllers
    NSMutableArray *viewControllers = [NSMutableArray array];
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *vc = obj;
        if ([obj isKindOfClass:[ZXTabBarItemController class]]) {
            ZXTabBarItemController *item = obj;
            if (item.storyboardName) {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:item.storyboardName bundle:nil];
                if (item.storyboardID) {
                    vc = [sb instantiateViewControllerWithIdentifier:item.storyboardID];
                } else {
                    vc = [sb instantiateInitialViewController];
                }
                vc.tabBarItem = item.tabBarItem;
            }
        }
        [viewControllers addObject:vc];
    }];
    [self setViewControllers:viewControllers animated:NO];
    
    // tabBar
    if (_selectedItemColor) {
        self.tabBar.tintColor = _selectedItemColor;
    }
    
    // tabBar items
    if (_originalItemImage) {
        [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.image = [obj.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            obj.selectedImage = [obj.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation ZXTabBarItemController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
