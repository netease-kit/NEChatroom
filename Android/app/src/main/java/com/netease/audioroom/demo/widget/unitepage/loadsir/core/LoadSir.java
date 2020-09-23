package com.netease.audioroom.demo.widget.unitepage.loadsir.core;

import androidx.annotation.NonNull;


import com.netease.audioroom.demo.widget.unitepage.loadsir.LoadSirUtil;
import com.netease.audioroom.demo.widget.unitepage.loadsir.callback.BaseCallback;

import java.util.ArrayList;
import java.util.List;


public class LoadSir {
    private static volatile LoadSir loadSir;
    private Builder builder;

    public static LoadSir getDefault() {
        if (loadSir == null) {
            synchronized (LoadSir.class) {
                if (loadSir == null) {
                    loadSir = new LoadSir();
                }
            }
        }
        return loadSir;
    }

    private LoadSir() {
        this.builder = new Builder();
    }

    private void setBuilder(@NonNull Builder builder) {
        this.builder = builder;
    }

    private LoadSir(Builder builder) {
        this.builder = builder;
    }

    public LoadService register(@NonNull Object target) {
        return register(target, null, null);
    }

    public LoadService register(Object target, BaseCallback.OnReloadListener onReloadListener) {
        return register(target, onReloadListener, null);
    }

    public <T> LoadService register(Object target, BaseCallback.OnReloadListener onReloadListener, Convertor<T>
            convertor) {
        TargetContext targetContext = LoadSirUtil.getTargetContext(target);
        return new LoadService<>(convertor, targetContext, onReloadListener, builder);
    }

    public static Builder beginBuilder() {
        return new Builder();
    }

    public static class Builder {
        private List<BaseCallback> callbacks = new ArrayList<>();
        private Class<? extends BaseCallback> defaultCallback;

        public Builder addCallback(@NonNull BaseCallback callback) {
            callbacks.add(callback);
            return this;
        }

        public Builder setDefaultCallback(@NonNull Class<? extends BaseCallback> defaultCallback) {
            this.defaultCallback = defaultCallback;
            return this;
        }

        List<BaseCallback> getCallbacks() {
            return callbacks;
        }

        Class<? extends BaseCallback> getDefaultCallback() {
            return defaultCallback;
        }

        public void commit() {
            getDefault().setBuilder(this);
        }

        public LoadSir build() {
            return new LoadSir(this);
        }

    }
}
