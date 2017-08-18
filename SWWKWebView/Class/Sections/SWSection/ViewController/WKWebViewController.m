//
//  WKWebViewController.m
//  SWWKWebView
//  webkitViewController与JS交互
//  Created by shiwei on 2017/8/16.
//  Copyright © 2017年 俊. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
#import <MobileCoreServices/MobileCoreServices.h>  //保存图片至手机相册


@interface WKWebViewController ()<WKUIDelegate,WKScriptMessageHandler,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    
    UIImagePickerController *_pickerVC;
}

/**
 @abstract WKWebView;
 */
@property(nonatomic, strong)WKWebView *webView;
@end


@implementation WKWebViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"WKWebViewMessageHandler";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpSubviews];
}
-(void)setUpSubviews {
    
    //创建并配置WKWebView的相关参数
    //1、WKWebViewConfiguration:是WKWebView的配置类，里面存放着初始化WK的一切属性。
    //2、WKUserContentController:为JS提供一个发送信息的通道并且可以向页面注入JS的类，WKUserContentController对象可以注册多个addScriptMessageHandler;
    //3、addScriptMessageHandler:name:有2个参数，第一个参数是userContentController的代理对象，第二参数是JS里发送postMmessage的对象。添加一个脚本信息处理器时，同时需要在JS中添加window.webkit.messageHandlers.<name>.postMessage(<messageBody>)才能起作用。
    
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    //1.WKUserContentController
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:self name:@"Share"];
    [userContentController addScriptMessageHandler:self name:@"Camera"];
    configuration.userContentController = userContentController;
    //2.WKPreferences
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 40.0;
    configuration.preferences = preferences;
    //3.WKDataDetecorTypes
    configuration.dataDetectorTypes = WKDataDetectorTypeAll;
    
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    //loadFileURL方法通常用于加载服务器的HTML页面或者JS，而loadHTMLString通常用于加载本地HTML或者JS
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WKWebViewMessageHandler" ofType:@"html"];
    NSString *fileURL = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:fileURL baseURL:baseURL];
    self.webView.UIDelegate = self;
   
    [self.view addSubview:self.webView];
}


#pragma mark----->>WKUIDelegate
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler();
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark---->>WKScriptMessageHandler
/**
 *  JS 调用 OC 时 webview 会调用此方法
 *
 *  @param userContentController  webview中配置的userContentController 信息
 *  @param message                JS执行传递的消息
 */
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    //JS调用OC的方法
    //message.body就是JS里传过来的对象
    NSLog(@"body:%@",message.body);
    if ([message.name isEqualToString:@"Share"]) {
        
        [self shareWithInfomation:message.body];
    }else if ([message.name isEqualToString:@"Camera"]) {
        
        [self camera];
    }
}
#pragma mark---->>Method
-(void)shareWithInfomation:(NSDictionary *)dic {
    
    if (![dic isKindOfClass:[NSDictionary class]]) {
        
        return;
    }
    
    NSString *title = dic[@"title"];
    NSString *content = dic[@"content"];
    NSString *url = dic[@"url"];
    
    //这里写分享的代码
    NSLog(@"要分享了哦");
    
    //OC反馈给JS分享结果
    NSString *JSResult = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
    [self.webView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        NSLog(@"error:%@",error);
    }];
    
}

-(void)camera {
    
    //在这里写 调用打开相册的代码
    [self selectImageFromPhotosAlbum];
}
-(void)selectImageFromPhotosAlbum {
    
    _pickerVC = [[UIImagePickerController alloc] init];
    _pickerVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    _pickerVC.allowsEditing = YES;
    _pickerVC.delegate = self;
    [self presentViewController:_pickerVC animated:YES completion:nil];
}
#pragma mark UIImagePickerControllerDelegate
//该代理方法仅适用于只选取图片时
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    
    NSLog(@"选择图片完毕----image:%@----info:%@",image,editingInfo);
};
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        UIImage *myImage = nil;
        myImage = info[UIImagePickerControllerEditedImage];
        
        //保存图片至相册
        UIImageWriteToSavedPhotosAlbum(myImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 图片保存完毕的回调
- (void) image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSLog(@"save success!");
    
    //OC反馈给JS相册结果,将结果返回JS
    
    NSString *JSResult = [NSString stringWithFormat:@"cameraResult('%@')",@"保存相册照片成功"];
    
    [self.webView evaluateJavaScript:JSResult completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        NSLog(@"%@----%@",result, error);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
@end

















