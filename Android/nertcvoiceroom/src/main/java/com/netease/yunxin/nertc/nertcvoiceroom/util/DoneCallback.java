package com.netease.yunxin.nertc.nertcvoiceroom.util;

import com.netease.nimlib.sdk.RequestCallback;

public class DoneCallback<T> implements RequestCallback<T> {
    private final Runnable runnable;

    public DoneCallback(Runnable runnable) {
        this.runnable = runnable;
    }

    private void done() {
        if (runnable != null) {
            runnable.run();
        }
    }

    @Override
    public void onSuccess(T param) {
        done();
    }

    @Override
    public void onFailed(int code) {
        done();
    }

    @Override
    public void onException(Throwable exception) {
        done();
    }
}
