package com.netease.audioroom.demo.widget.unitepage.loadsir.core;


import com.netease.audioroom.demo.widget.unitepage.loadsir.callback.BaseCallback;

public interface Convertor<T> {
    Class<? extends BaseCallback> map(T t);
}
