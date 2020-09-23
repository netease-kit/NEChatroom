package com.netease.audioroom.demo.app;

import android.content.Context;

import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.SDKOptions;
import com.netease.nimlib.sdk.util.NIMUtil;
import com.orhanobut.logger.AndroidLogAdapter;
import com.orhanobut.logger.CsvFormatStrategy;
import com.orhanobut.logger.DiskLogAdapter;
import com.orhanobut.logger.Logger;

import java.io.File;

public class NimApplication extends BaseApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        DemoCache.init(this);
        NIMClient.init(this, null, getOptions());
        if (NIMUtil.isMainProcess(this)) {
            initLog();
        }
    }

    private void initLog() {
        Logger.addLogAdapter(new AndroidLogAdapter());
        Logger.addLogAdapter(new DiskLogAdapter(CsvFormatStrategy.newBuilder()
                .logStrategy(new DiskLogStrategy(this))
                .tag("APP")
                .build()));
    }

    private SDKOptions getOptions() {
        SDKOptions options = new SDKOptions();
        options.sdkStorageRootPath = ensureLogDirectory(this);
        return options;
    }

    public static String ensureLogDirectory(Context context) {
        File log = context.getExternalFilesDir("nim");
        if (log == null) {
            log = context.getDir("nim", Context.MODE_PRIVATE);
        }
        return log.getAbsolutePath();
    }

}
