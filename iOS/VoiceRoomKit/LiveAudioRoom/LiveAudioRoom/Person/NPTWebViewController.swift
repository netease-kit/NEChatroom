// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import WebKit

class NPTWebViewController: UIViewController {
  var urlString: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(webView)
    if let urlString = urlString,
       let url = URL(string: urlString) {
      let request = URLRequest(url: url)
      webView.load(request)
    }
  }

  lazy var webView: WKWebView = {
    let view = WKWebView(frame: self.view.frame)
    return view
  }()
}
