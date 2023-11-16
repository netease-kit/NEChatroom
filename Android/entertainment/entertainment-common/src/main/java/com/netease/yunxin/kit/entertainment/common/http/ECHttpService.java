// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.http;

import android.content.Context;
import com.netease.yunxin.kit.common.network.ServiceCreator;
import com.netease.yunxin.kit.entertainment.common.BuildConfig;
import com.netease.yunxin.kit.entertainment.common.model.ECModelResponse;
import com.netease.yunxin.kit.entertainment.common.model.NemoAccount;
import java.util.HashMap;
import java.util.Map;
import retrofit2.Callback;

public class ECHttpService {
  private final ServiceCreator serviceCreator = new ServiceCreator();
  private ECServerApi serverApi;

  private static volatile ECHttpService mInstance;

  private ECHttpService() {}

  public static ECHttpService getInstance() {
    if (null == mInstance) {
      synchronized (ECHttpService.class) {
        if (mInstance == null) {
          mInstance = new ECHttpService();
        }
      }
    }
    return mInstance;
  }

  public void initialize(Context context, String serverUrl) {
    serviceCreator.init(
        context,
        serverUrl,
        BuildConfig.DEBUG ? ServiceCreator.LOG_LEVEL_BODY : ServiceCreator.LOG_LEVEL_BASIC,
        null);
    serverApi = serviceCreator.create(ECServerApi.class);
  }

  public void addHeader(String key, String value) {
    serviceCreator.addHeader(key, value);
  }

  public void createAccount(Callback<ECModelResponse<NemoAccount>> callback) {
    Map<String, Object> map = new HashMap<>();
    map.put("sceneType", 2);
    if (serverApi != null) {
      serverApi.createAccount(map).enqueue(callback);
    }
  }
}
