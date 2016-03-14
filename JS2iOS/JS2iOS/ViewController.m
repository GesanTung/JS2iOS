//
//  ViewController.m
//  JS2iOS
//
//  Created by tung on 16/3/4.
//  Copyright © 2016年 trs. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "SDPhotoBrowser.h"

#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSTungExport <JSExport>

- (void)pushViewController:(NSString *)view title:(NSString *)title;

-(void)testMethodWithParam1:(NSString *)param1 param2:(NSString *)param2;

-(void)testLog:(NSString *)logText;
-(void)testShowTextOnHtml:(NSString *)showText;
-(void)test:(NSNumber *)param1 method:(NSString *)param2;
-(void)testArray:(NSArray *)dataArray;

-(BOOL)login:(NSString*)name password:(NSString*)pwd;

- (void)updateWebView;

- (void)preview:(int)index  images:(id)image;

-(NSString*)responeToWeb;

@end


@interface ViewController ()<UIWebViewDelegate,SDPhotoBrowserDelegate>
{
    UIWebView *myWebView;
    JSContext *context;
    NSString  *gImageUrl;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    class_addProtocol([ViewController class],@protocol(JSTungExport));
    
    // Do any additional setup after loading the view.
    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"js_1.html"];
    
    //NSString *path = @"http://192.168.5.180:8080/trs/jsoc.html";
    
    myWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
    myWebView.delegate = self;
    NSURL *URL = [NSURL URLWithString:path];
    NSURLRequest *requestww = [NSURLRequest requestWithURL:URL];
    [myWebView loadRequest:requestww];
    [self.view addSubview:myWebView];

}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    // 以 html title 设置 导航栏 title
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];

    context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    // 打印异常
    context.exceptionHandler = ^(JSContext *ctx, JSValue *exceptionValue) {
        ctx.exception = exceptionValue;
        NSLog(@"%@",ctx.exception);
    };
    
    
    context[@"Native"] = self; //以JSExport 协议关联 native 的方法
    
    context[@"log"] = ^(NSString *str){//以block 形式关联 JavaScript function
        NSLog(@"%@", str);
    };
    
    //
    //给网页图片添加点击事件
    NSString *js = [NSString stringWithFormat:
                    @"var imgs=document.getElementsByTagName('img');"
                    "var length=imgs.length;"
                    "for(var i=0;i<length;i++){img=imgs[i];"
                    "img.onclick=function(){Native.previewImages(0,this.src);}}"];
    [context evaluateScript:js];
    

    __weak typeof(self) weakSelf = self;
    context[@"addSubView"] = ^(NSString *viewname) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 500, 300, 100)];
        view.backgroundColor = [UIColor redColor];
        UISwitch *sw = [[UISwitch alloc]init];
        [view addSubview:sw];
        [weakSelf.view addSubview:view];
    };
}

- (void)updateWeb:(NSString*)name{
    //网页元素增删改
    NSString *js = [NSString stringWithFormat:
                    @"var para=document.createElement('p');"
                    "var node=document.createTextNode('欢迎'+'%@' + '登入');"
                    "para.appendChild(node);"
                    
                    "var element=document.getElementById('d1');"
                    "element.appendChild(para);"
                    ,name];
    
    [context evaluateScript:js];
}

-(void)testArray:(NSArray *)dataArray{
    NSLog(@"testArray = %@", dataArray);
}

-(NSString*)responeToWeb{
    return  @"respone by ios = hello web";
}

-(BOOL)login:(NSString*)name password:(NSString*)pwd{
    [self updateWeb:name];
    return  true;
}

-(void)test:(NSNumber *)param1 method:(NSString *)param2{
    NSLog(@"test>>> param1 = %@, method=%@ ",param1, param2);
}
-(void)testMethodWithParam1:(NSString *)param1 param2:(NSString *)param2{
    NSLog(@"testMethodWithParam1>>> param1 = %@, param2=%@ ",param1, param2);
}

-(void)testLog:(NSString *)logText{
    NSLog(@"testLog>>> logText = %@ ", logText);
}

-(void)testShowTextOnHtml:(NSString *)showText{
    NSString *resultText = [NSString stringWithFormat:@"%@ date=%@",showText, [NSDate date]];
    NSLog(@"%@", resultText);
    [context[@"showResult"] callWithArguments:@[resultText]];//回调JS的方法showResult(resultText);
}

- (void)updateWebView{
    NSURL *URL = [NSURL URLWithString:@"http://3g.163.com/ntes/special/0034073A/wechat_article.html?docid=BI42OEHU000915BF"];
    NSURLRequest *requestww = [NSURLRequest requestWithURL:URL];
    [myWebView loadRequest:requestww];
}

- (void)preview:(int)index  images:(id)image{
    SDPhotoBrowser* browser = [[SDPhotoBrowser alloc]initWithFrame:self.view.frame];
    browser.sourceImagesContainerView = self.view;
    browser.delegate = self;
    gImageUrl = image;
    browser.imageCount = 1;
    [browser show];
}

// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    return [NSURL URLWithString:gImageUrl];
}

@end
