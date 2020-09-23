package com.netease.audioroom.demo.util;

import android.annotation.SuppressLint;
import android.content.Context;
import android.widget.Toast;

import com.netease.audioroom.demo.cache.DemoCache;


public class ToastHelper {

    private static Toast sToast;


    private ToastHelper() {

    }

    public static void showToast(String text) {
        showToastInner(text, Toast.LENGTH_SHORT);
    }

    public static void showToast(Context context, int stringId) {
        showToastInner(DemoCache.getContext().getString(stringId), Toast.LENGTH_SHORT);
    }


    public static void showToastLong(String text) {
        showToastInner(text, Toast.LENGTH_LONG);
    }

    public static void showToastLong(int stringId) {
        showToastInner(DemoCache.getContext().getString(stringId), Toast.LENGTH_LONG);
    }


    private static void showToastInner(String text, int duration) {
        ensureToast();
        sToast.setText(text);
        sToast.setDuration(duration);
        sToast.show();
    }


    @SuppressLint("ShowToast")
    private static void ensureToast() {
        if (sToast != null) {
            return;
        }
        synchronized (ToastHelper.class) {
            if (sToast != null) {
                return;
            }
            sToast = Toast.makeText(DemoCache.getContext(), " ", Toast.LENGTH_SHORT);
        }
    }
}
