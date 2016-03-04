# JavaScript 与 iOS
### 业务背景
1. Webview修改html网页中字体，调整or获取网页图片
2. JavaScript 调用 iOS native 方法

###解决方案
Webview 执行js代码 

- stringByEvaluatingJavaScriptFromString

**exp1：修改网页宽，重置图片size**

	- (void)setWebViewHTMLProperty{
       //修改服务器页面的meta的值
		 NSString *meta = [NSString     
		 stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = 
		 \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-
		 scalable=no\"", self.frame.size.width];
		[self stringByEvaluatingJavaScriptFromString:meta];
    
        [self stringByEvaluatingJavaScriptFromString:
	     @"var script = document.createElement('script');"
	     "script.type = 'text/javascript';"
	     "script.text = \"function ResizeImages() { "
	     "var var myimg;"
	     "var maxwidth = 300;"
	     "for(i=0;i <document.images.length;i++){"
	     "myimg = document.images[i];"
	     "if(myimg.width > maxwidth){"
	     "myimg.style.width = '95%%';"
	     "myimg.style.height = 'auto';"
	     "}"
	     "}"
	     "}\";"
       "document.getElementsByTagName('head')[0].appendChild(script);"];
       [self stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
    } 

**API 说明**

_- stringByEvaluatingJavaScriptFromString:
Returns the result of running a JavaScript script. Although this method is not deprecated, best practice is to use the evaluateJavaScript:completionHandler: method of the WKWebView class instead._ 


_New apps should instead use the evaluateJavaScript:completionHandler: method from the WKWebView class. Legacy apps should adopt that method if possible._


_The stringByEvaluatingJavaScriptFromString: method waits synchronously for JavaScript evaluation to complete. If you load web content whose JavaScript code you have not vetted, invoking this method could hang your app. Best practice is to adopt the WKWebView class and use its evaluateJavaScript:completionHandler: method instead._

[Apple Developer Link : stringByEvaluatingJavaScriptFromString](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIWebView_Class/) 

2 JavaScript 调用iOS native

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
navigationType:(UIWebViewNavigationType)navigationType


	    HTML 源码
		<html>
		    <head>
		        <title>测试网页</title>
		    </head>
		    <body>
		        <br />
		        <a href="tung://login?func=login&name=zengjing&password=123456">登陆</a>
		    </body>
		</html>
       
       iOS 源码
		- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
		{
		    NSURL *url = [request URL];
		    if([[url scheme] isEqualToString:@"tung"]) {//获取协议名
		        
		        if([[url host] isEqualToString:@"login"])//获取域
		        {
		            //获取URL上面的参数
		            NSDictionary *params = [self getParams:[url query]];
                   [params objectForKey:@"func"];
		        }
		        return NO;
		    }
		    return YES;
		} 



- Webview添加手势，iOS传入当前时间相应坐标通过js 代码 获取对应元素
        
		 - (void)handleGestureRecognizer:(UITapGestureRecognizer *)gesture{
		    if (gesture.state == UIGestureRecognizerStateEnded) {
		        NSString *path = [[NSBundle mainBundle] pathForResource:@"webscript" ofType:@"js"];
		        NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		        [self.webView stringByEvaluatingJavaScriptFromString:script];
		        
		        CGPoint point = [gesture locationInView:self.webView];
		        
		        //// Get the URL link at the touch location
		        NSString *function = [NSString stringWithFormat:@"script.getElement(%f,%f);", point.x, point.y];
		        NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:function];
		        
		        if(result != nil && result.length != 0) {
		            NSLog(@"%@", result);
		            NSDictionary *dict = [NSString JSONObjectWithString:result];
		            if (dict[@"docid"]&&dict[@"channelId"]&&[dict[@"channelId"] length]&&[dict[@"docid"] length]) {
		                NSMutableDictionary *pDict = [NSMutableDictionary dictionaryWithDictionary:dict];
		                if ([dict[@"docid"]intValue]==-1) {
		                    [pDict setObject:@"5" forKey:@"clickType"];
		                }else{
		                    [pDict setObject:@"1" forKey:@"clickType"];
		                }
		                [self goNextPageDetail:pDict];
		                _gDetailAction = YES;
		            }else{
		                _gDetailAction = NO;
		            }
		
		        }
		        gesture.view.accessibilityActivationPoint = point;
		    }
		}

	    getLink = function(x,y) {
	        var tags = "";
	        var e = "";
	        var offset = 0;
	        var docid = "";
	        var channelId = "";
	        var url ="";
	        var result = "";
	        while ((tags.length == 0) && (offset < 5)) {
	            e = document.elementFromPoint(x,y+offset);
	            while (e) {
	                if (e.href) {
	                    if(e.getAttribute('docid')){
	                        docid= e.getAttribute('docid');
	                    }
	                    if(e.getAttribute('channelId')){
	                        channelId= e.getAttribute('channelId');
	                    }
	                    
	                    url= e.href;
	                    
	                    result =  '{ "url" : "'+url+'" , "channelId" : "'+ channelId +'", "docid" : "'+ docid +'"}';
	                    break;
	                }
	                e = e.parentNode;
	            }
	
	            offset++;
	        }
	        if (result != null && result.length > 0){
	            return result;}
	        else {
	            return null;
	        }
	    }


***
***
###Pro Java​Script​Core
Webview 执行js代码

- evaluateScript

        JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"]
        context.evaluateScript("js")
        
JavaScript 调用iOS native

- Block or JSExport

        【Block】
		JSContext *context = [[JSContext alloc]init];
		context[@"log"] = ^(NSString *msg){
            NSLog(@"trs:%@",msg);
		};
		[contextSecond evaluateScript:@"log('300027')"];
        
        【JSExport】
		@protocol LogJSExpProtocol <JSExport>
        - (Bool)log;
        @end
        @interface LogObject : NSObject <LogJSExpProtocol>
        @end

		.m
		#import "LogObject.h"
		@implementation LogObject
		
		-(void)log:(NSString*)string {
		     NSLog(@"trs:%@",msg);
		}
		@end
		
		- (void) testLog
		{
		    JSContext *context = [[JSContextalloc]init];
		    context[@"ios"] = [[LogObject alloc]init];
		    [context evaluateScript:@"ios.log(\"300027\")"];
		}
        


###推荐参考知识点
* Java​Script​Core,WKwebview 
* React Native
* DOM

