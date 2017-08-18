//
//  ViewController.m
//  SWWKWebView
//
//  Created by shiwei on 2017/8/16.
//  Copyright © 2017年 俊. All rights reserved.
//

#import "ViewController.h"
#import "WKWebViewController.h"


@interface ViewController ()
@end


@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpSubviews];
}
-(void)setUpSubviews {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(50, 150, 300, 50);
    btn.backgroundColor = [UIColor cyanColor];
    [btn setTitle:@"WKWebViewMessageHandler" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
-(void)buttonAction:(UIButton *)sender {
    
    WKWebViewController *webVC = [WKWebViewController new];
    [self.navigationController pushViewController:webVC animated:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
