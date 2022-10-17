// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIWebViewController.h"
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>

@interface NEUIWebViewController ()
@property(strong, nonatomic) WKWebView *webview;
@property(strong, nonatomic) NSString *urlString;
@end

@implementation NEUIWebViewController
- (instancetype)initWithUrlString:(NSString *)urlString {
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
@end
