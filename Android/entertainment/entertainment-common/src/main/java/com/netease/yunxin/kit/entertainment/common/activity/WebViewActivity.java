// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.activity;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.RelativeLayout;
import com.netease.yunxin.kit.entertainment.common.Constants;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.databinding.ActivityWebviewBinding;

public class WebViewActivity extends BasePartyActivity {

  private ActivityWebviewBinding binding;
  private static final String SCHEME_HTTP = "http";
  private static final String SCHEME_HTTPS = "https";

  private String title;
  private String url;

  private WebView webView;

  @Override
  protected void init() {
    title = getIntent().getStringExtra(Constants.INTENT_KEY_TITLE);
    url = getIntent().getStringExtra(Constants.INTENT_KEY_URL);
    paddingStatusBarHeight(binding.getRoot());
    initViews();
  }

  @Override
  protected View getRootView() {
    binding = ActivityWebviewBinding.inflate(getLayoutInflater());
    return binding.getRoot();
  }

  private void initViews() {
    binding.titleBar.setTitle(title);

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
    webView.getSettings().setAllowFileAccessFromFileURLs(false);
    webView.getSettings().setAllowUniversalAccessFromFileURLs(false);
    webView.removeJavascriptInterface("searchBoxJavaBridge_");
    webView.removeJavascriptInterface("accessibility");
    webView.removeJavascriptInterface("accessibilityTraversal");
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
}
