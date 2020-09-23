package com.netease.audioroom.demo.util;

public class Network {
    private boolean wifi;
    private boolean mobile;
    private boolean connected;
    private static Network network;

    public static Network getInstance() {
        if (null == network) {
            network = new Network();
        }
        return network;
    }


    private Network() {
    }

    public boolean isConnected() {
        return connected;
    }

    public void setConnected(boolean connected) {
        this.connected = connected;
    }

    public boolean isWifi() {
        return wifi;
    }

    public void setWifi(boolean wifi) {
        this.wifi = wifi;
    }

    public boolean isMobile() {
        return mobile;
    }

    public void setMobile(boolean mobile) {
        this.mobile = mobile;
    }

}
