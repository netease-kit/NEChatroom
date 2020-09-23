package com.netease.audioroom.demo.util;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.AsyncTask;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

public class AudioChooser {
    public static Intent intent(Context context) {
        Intent intent;
        intent = new Intent();
        intent.setAction(Intent.ACTION_GET_CONTENT);
        intent.setType("audio/*");
        return Intent.createChooser(intent, "choose audio file");
    }

    public static void choose(Activity activity, int code) {
        try {
            activity.startActivityForResult(intent(activity), code);
        } catch (Throwable tr) {
            tr.printStackTrace();
            ToastHelper.showToast("无法打开文件选择器");
        }
    }

    public interface Callback<V> {
        void call(V value);
    }

    public static void result(@NonNull final Context context,
                              @NonNull Intent intent,
                              @NonNull final Callback<String> callback) {
        final Uri uri = intent.getData();
        if (uri == null) {
            callback.call(null);
            return;
        }

        new AsyncTask<Void, Void, String>() {
            @Override
            protected String doInBackground(Void... voids) {
                return copy(context, uri);
            }

            @Override
            protected void onPostExecute(String path) {
                callback.call(path);

            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

    private static String copy(Context context, Uri uri) {
        String name = String.valueOf(uri.hashCode());
        File dir = context.getExternalFilesDir("music");
        File file = new File(dir, name);

        InputStream is = null;
        OutputStream os = null;

        try {
            is = context.getContentResolver().openInputStream(uri);
            os = new FileOutputStream(file);
            CommonUtil.copyStream(is, os);
        } catch (Throwable tr) {
            tr.printStackTrace();
            return null;
        } finally {
            CommonUtil.closeQuiet(is);
            CommonUtil.closeQuiet(os);
        }

        return file.getAbsolutePath();
    }
}
