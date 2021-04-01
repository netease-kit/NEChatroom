package com.netease.audioroom.demo.widget.lrc;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.netease.audioroom.demo.http.LyricDownloadService;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.Lrc;

import java.util.List;
import java.util.concurrent.Executors;

import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;

public class LyricDown {

    public static final String BASE_CDN_URL = "https://yx-web-nosdn.netease.im/";

    public static void download(String url,final DownloadListener downloadListener) {
        if(url .contains(BASE_CDN_URL)){
            url.replace(BASE_CDN_URL,"");
        }else {
            return;
        }

        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(BASE_CDN_URL)
                //通过线程池获取一个线程，指定callback在子线程中运行。
                .callbackExecutor(Executors.newSingleThreadExecutor())
                .build();

        LyricDownloadService service = retrofit.create(LyricDownloadService.class);

        Call<ResponseBody> call = service.download(url);
        call.enqueue(new Callback<ResponseBody>() {
            @Override
            public void onResponse(@NonNull Call<ResponseBody> call, @NonNull final Response<ResponseBody> response) {
                if(response.body() != null) {
                      List<Lrc> lrcs =  LrcHelper.parseInputStream(response.body().byteStream());
                      if(lrcs != null){
                          new Handler(Looper.getMainLooper()).post(() ->{
                              downloadListener.onSuccess(lrcs);
                          });
                      }else {
                          downloadListener.onFail("解析错误");
                      }
                }else {
                    downloadListener.onFail("返回为空");
                }
            }

            @Override
            public void onFailure(@NonNull Call<ResponseBody> call, @NonNull Throwable throwable) {
                downloadListener.onFail("网络错误～");
            }
        });
    }

    public interface DownloadListener {
       void onSuccess(List<Lrc> lrcs);

        void onFail(String errorInfo);//下载失败
    }
}
