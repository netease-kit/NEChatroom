// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.main;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.netease.yunxin.app.chatroom.Constants;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.activity.BaseActivity;
import com.netease.yunxin.kit.voiceroomkit.ui.statusbar.StatusBarConfig;

public class WebViewActivity extends BaseActivity {

  private static final String SCHEME_HTTP = "http";
  private static final String SCHEME_HTTPS = "https";

  private String title;
  private String url;

  private WebView webView;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_webview);
    title = getIntent().getStringExtra(Constants.INTENT_KEY_TITLE);
    url = getIntent().getStringExtra(Constants.INTENT_KEY_URL);
    initViews();
  }

  private void initViews() {
    View close = findViewById(R.id.iv_close);
    close.setOnClickListener(v -> finish());

    TextView tvTitle = findViewById(R.id.tv_title);
    tvTitle.setText(title);

    webView = initWebView();
    ViewGroup webViewGroup = findViewById(R.id.rl_root);
    RelativeLayout.LayoutParams layoutParams =
        new RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
    layoutParams.addRule(RelativeLayout.BELOW, R.id.title_divide);
    webView.setLayoutParams(layoutParams);
    webViewGroup.addView(webView);
    webView.loadUrl(url);
  }

  @SuppressLint("SetJavaScriptEnabled")
  private WebView initWebView() {
    WebView webView = new WebView(getApplicationContext());
    webView.setOnLongClickListener(v -> true);

    WebViewClient client =
        new WebViewClient() {

          @Override
          public boolean shouldOverrideUrlLoading(WebView view, String url) {
            Uri uri = Uri.parse(url);
            String scheme = uri.getScheme();
            boolean result =
                TextUtils.isEmpty(scheme)
                    || (!scheme.equals(SCHEME_HTTP) && !scheme.equals(SCHEME_HTTPS));
            if (result) {
              Intent intent = new Intent(Intent.ACTION_VIEW);
              intent.setData(uri);
              intent.addCategory(Intent.CATEGORY_DEFAULT);
              if (intent.resolveActivity(getPackageManager()) != null) {
                startActivity(intent);
              } else {
                result = false;
              }
            }
            return result;
          }
        };
    webView.setWebViewClient(client);
    webView.setWebChromeClient(new WebChromeClient());

    webView.getSettings().setUseWideViewPort(true);
    webView.getSettings().setLoadWithOverviewMode(true);

    webView.getSettings().setSupportZoom(true);
    webView.getSettings().setBuiltInZoomControls(true);
    webView.getSettings().setDisplayZoomControls(false);

    webView.getSettings().setDomStorageEnabled(true);
    webView.getSettings().setBlockNetworkImage(false);

    webView.getSettings().setJavaScriptEnabled(true);
    return webView;
  }

  @Override
  public void onBackPressed() {
    if (webView.canGoBack()) {
      webView.goBack();
      return;
    }
    super.onBackPressed();
  }

  @Override
  protected StatusBarConfig provideStatusBarConfig() {
    return new StatusBarConfig.Builder()
        .statusBarDarkFont(true)
        .statusBarColor(android.R.color.white)
        .fitsSystemWindow(true)
        .build();
  }
}
