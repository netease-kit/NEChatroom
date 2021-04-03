package com.netease.audioroom.demo.app;


import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.alog.BasicInfo;
import com.netease.audioroom.demo.BuildConfig;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.util.IconFontUtil;
import com.netease.neliveplayer.sdk.NELivePlayer;
import com.netease.neliveplayer.sdk.model.NESDKConfig;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.SDKOptions;
import com.netease.nimlib.sdk.util.NIMUtil;
import com.netease.yunxin.android.lib.network.common.NetworkClient;

import java.util.Map;

public class NimApplication extends BaseApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        NetworkClient.getInstance().configBaseUrl(BuildConfig.SERVER_BASE_URL)
                .appKey(BuildConfig.NIM_APP_KEY)
                .configDebuggable(true);
        // 播放器初始化，用于 CDN 拉流
        NESDKConfig config = new NESDKConfig();
        config.dataUploadListener = new NELivePlayer.OnDataUploadListener() {
            @Override
            public boolean onDataUpload(String url, String data) {
                ALog.e("Player===>", "stream url is " + url + ", detail data is " + data);
                return true;
            }

            @Override
            public boolean onDocumentUpload(String url, Map<String, String> params, Map<String, String> filepaths) {
                return false;
            }
        };
        NELivePlayer.init(getApplicationContext(), config);

        DemoCache.init(this);
        NIMClient.init(this, null, getOptions());
        if (NIMUtil.isMainProcess(this)) {
            IconFontUtil.getInstance().init(this);
            initLog();
        }
    }

    private void initLog() {
        ALog.init(this, BuildConfig.DEBUG ? ALog.LEVEL_ALL : ALog.LEVEL_INFO);

        BasicInfo basicInfo = new BasicInfo.Builder()
                .name(getString(R.string.app_name),true)
                .version("v"+BuildConfig.VERSION_NAME)
                .baseUrl(BuildConfig.SERVER_BASE_URL)
                .deviceId(this)
                .packageName(this)
                .gitHashCode(BuildConfig.GIT_COMMIT_HASH)
                .imVersion(BuildConfig.IM_VERSION)
                .nertcVersion(BuildConfig.NERTC_VERSION)
                .build();
        ALog.logFirst(basicInfo);
    }

    private SDKOptions getOptions() {
        SDKOptions options = new SDKOptions();
        options.appKey = BuildConfig.NIM_APP_KEY;
        return options;
    }

}
