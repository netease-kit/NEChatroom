package com.netease.yunxin.nertc.nertcvoiceroom.util;

import com.netease.nimlib.sdk.RequestCallback;

public class RequestCallbackEx<T> implements RequestCallback<T> {
    private final RequestCallback<T> callback;

    public RequestCallbackEx(RequestCallback<T> callback) {
        this.callback = callback;
    }

    @Override
    public void onSuccess(T param) {
        if (callback != null) {
            callback.onSuccess(param);
        }
    }

    @Override
    public void onFailed(int code) {
        if (callback != null) {
            callback.onFailed(code);
        }
    }

    @Override
    public void onException(Throwable exception) {
        if (callback != null) {
            callback.onException(exception);
        }
    }
}
