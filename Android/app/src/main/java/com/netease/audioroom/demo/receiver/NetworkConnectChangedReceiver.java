package com.netease.audioroom.demo.receiver;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import com.netease.audioroom.demo.util.Network;
import com.netease.audioroom.demo.util.NetworkChange;

public class NetworkConnectChangedReceiver extends BroadcastReceiver {
    Network network = Network.getInstance();
    @Override
    public void onReceive(Context context, Intent intent) {
        if (ConnectivityManager.CONNECTIVITY_ACTION.equals(intent.getAction())) {
            ConnectivityManager manager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo activeNetworkInfo = manager.getActiveNetworkInfo();
            if (activeNetworkInfo != null) {
                if (activeNetworkInfo.isConnected()) {
                    network.setConnected(true);
                    //通知观察者网络状态已改变
                    NetworkChange.getInstance().notifyDataChange(network);
                } else {
                    network.setConnected(false);
                    //通知观察者网络状态已改变 当前没有网络连接
                    NetworkChange.getInstance().notifyDataChange(network);
                }
            } else {
                network.setWifi(false);
                network.setMobile(false);
                network.setConnected(false);
                //通知观察者网络状态已改变
                NetworkChange.getInstance().notifyDataChange(network);
//                ToastHelper.showToast("当前没有网络连接，请确保你已经打开网络");
            }
        }


    }
}
