//
//  ViewController.m
//  JS2iOS
//
//  Created by tung on 16/3/4.
//  Copyright © 2016年 trs. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSTungExport <JSExport>

- (void)pushViewController:(NSString *)view title:(NSString *)title;

-(void)testMethodWithParam1:(NSString *)param1 param2:(NSString *)param2;

-(void)testLog:(NSString *)logText;
-(void)testShowTextOnHtml:(NSString *)showText;
-(void)test:(NSNumber *)param1 method:(NSString *)param2;
-(void)testArray:(NSArray *)dataArray;

-(NSString*)responeToWeb;

@end


@interface ViewController ()<UIWebViewDelegate>
{
    UIWebView *myWebView;
    JSContext *context;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    class_addProtocol([ViewController class],@protocol(JSTungExport));
    
    // Do any additional setup after loading the view.
    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"js_1.html"];

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

    __weak typeof(self) weakSelf = self;
    context[@"addSubView"] = ^(NSString *viewname) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 500, 300, 100)];
        view.backgroundColor = [UIColor redColor];
        UISwitch *sw = [[UISwitch alloc]init];
        [view addSubview:sw];
        [weakSelf.view addSubview:view];
    };
}


-(void)testArray:(NSArray *)dataArray{
    NSLog(@"testArray = %@", dataArray);
}

-(NSString*)responeToWeb{
    return  @"respone by ios = hello web";
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

@end
