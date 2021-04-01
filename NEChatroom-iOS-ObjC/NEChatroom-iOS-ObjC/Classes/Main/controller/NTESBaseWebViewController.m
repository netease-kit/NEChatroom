//
//  NTESBaseWebViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESBaseWebViewController.h"
#import <WebKit/WebKit.h>

@interface NTESBaseWebViewController ()
@property(strong,nonatomic)WKWebView *webview;
@property(strong,nonatomic)NSString *urlString;

@end

@implementation NTESBaseWebViewController

- (instancetype)initWithUrlString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        self.urlString = urlString;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webview];
    [self.webview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self loadWebView];
}

- (void)loadWebView {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlString]];
    [self.webview loadRequest:request];
}
- (WKWebView *)webview {
    if (!_webview) {
        _webview = [[WKWebView alloc] init];
    }
    return _webview;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
