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
                // todo network type
                if (activeNetworkInfo.isConnected()) {
                    network.setConnected(true);
                } else {
                    network.setConnected(false);
                }
            } else {
                network.setWifi(false);
                network.setMobile(false);
                network.setConnected(false);
            }
            NetworkChange.getInstance().notifyDataChange(network);
        }
    }
}
