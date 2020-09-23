package com.netease.yunxin.nertc.nertcvoiceroom.util;

import com.netease.nimlib.sdk.RequestCallback;

public class ConvertCallback<T, S> implements RequestCallback<S> {
    public interface Converter<S, T> {
        T convert(S param);
    }

    private final RequestCallback<T> callback;

    private final Converter<S, T> converter;

    public ConvertCallback(RequestCallback<T> callback, Converter<S, T> converter) {
        this.callback = callback;
        this.converter = converter;
    }

    @Override
    public void onSuccess(S param) {
        if (callback != null && converter != null) {
            callback.onSuccess(converter.convert(param));
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
