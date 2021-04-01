package com.netease.audioroom.demo.util;

import androidx.lifecycle.InitAwareLiveData;

public class NetworkChange {

    private static NetworkChange instance = null;

    // may be use ignore first event aware
    private InitAwareLiveData<Network> networkLiveData = new InitAwareLiveData<>();

    public InitAwareLiveData<Network> getNetworkLiveData() {
        return networkLiveData;
    }

    public static NetworkChange getInstance() {
        if (null == instance) {
            instance = new NetworkChange();
            // base application construction， set first value
            instance.notifyDataChange(Network.getInstance());
        }
        return instance;
    }
    //通知观察者数据改变

    public void notifyDataChange(Network net) {
        // net must not null
        Network last = networkLiveData.getValue();
        networkLiveData.postValue(net);
    }

}

