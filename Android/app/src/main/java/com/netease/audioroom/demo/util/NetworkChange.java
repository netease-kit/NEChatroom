package com.netease.audioroom.demo.util;



import java.util.Observable;

public class NetworkChange extends Observable {
    private static NetworkChange instance = null;

    public static NetworkChange getInstance() {
        if (null == instance) {
            instance = new NetworkChange();
        }
        return instance;
    }
    //通知观察者数据改变

    public void notifyDataChange(Network net) {
        setChanged();
        notifyObservers(net);
    }

}

