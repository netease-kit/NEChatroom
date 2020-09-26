package com.netease.audioroom.demo.http;

import android.content.Context;
import android.os.Handler;
import android.util.Log;


import com.netease.audioroom.demo.executor.NimTaskExecutor;
import com.orhanobut.logger.Logger;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.conn.ClientConnectionManager;
import org.apache.http.conn.params.ConnManagerParams;
import org.apache.http.conn.params.ConnPerRouteBean;
import org.apache.http.conn.scheme.PlainSocketFactory;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.conn.ssl.AllowAllHostnameVerifier;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.impl.conn.tsccm.ThreadSafeClientConnManager;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;

import java.net.UnknownHostException;
import java.util.Map;


public class NimHttpClient {

    private static final String TAG = "NimHttpClient";


    private NimHttpClient() {

    }

    public static NimHttpClient getInstance() {
        return InstanceHolder.INSTANCE;
    }


    /**
     * **************** Http Config & Thread pool & Http Client ******************
     */
    // 最大连接数
    private final static int MAX_CONNECTIONS = 10;

    // 获取连接的最大等待时间
    private final static int WAIT_TIMEOUT = 5 * 1000;

    // 每个路由最大连接数
    private final static int MAX_ROUTE_CONNECTIONS = 10;

    // 连接超时时间
    private final static int CONNECT_TIMEOUT = 5 * 1000;

    // 读取超时时间
    private final static int READ_TIMEOUT = 10 * 1000;

    private boolean inited = false;

    private HttpClient client;

    private ClientConnectionManager connManager;

    private NimTaskExecutor executor;

    private Handler uiHandler;

    public void init(Context context) {
        if (inited) {
            return;
        }
        inited = true;
        // init thread pool
        executor = new NimTaskExecutor("NIM_HTTP_TASK_EXECUTOR", new NimTaskExecutor.Config(1, 3, 10 * 1000, true));

        // init HttpClient supporting multi thread access
        HttpParams httpParams = new BasicHttpParams();
        // 设置最大连接数
        ConnManagerParams.setMaxTotalConnections(httpParams, MAX_CONNECTIONS);
        // 设置获取连接的最大等待时间
        ConnManagerParams.setTimeout(httpParams, WAIT_TIMEOUT);
        // 设置每个路由最大连接数
        ConnManagerParams.setMaxConnectionsPerRoute(httpParams, new ConnPerRouteBean(MAX_ROUTE_CONNECTIONS));
        // 设置连接超时时间
        HttpConnectionParams.setConnectionTimeout(httpParams, CONNECT_TIMEOUT);
        // 设置读取超时时间
        HttpConnectionParams.setSoTimeout(httpParams, READ_TIMEOUT);

        SchemeRegistry registry = new SchemeRegistry();
        registry.register(new Scheme("http", PlainSocketFactory.getSocketFactory(), 80));
        registry.register(new Scheme("https", SSLSocketFactory.getSocketFactory(), 443));

        SSLSocketFactory.getSocketFactory().setHostnameVerifier(new AllowAllHostnameVerifier());

        connManager = new ThreadSafeClientConnManager(httpParams, registry);
        client = new DefaultHttpClient(connManager, httpParams);

        uiHandler = new Handler(context.getMainLooper());

    }


    public void execute(String url, Map<String, String> headers, String body, NimHttpCallback callback) {
        execute(url, headers, body, true, callback);
    }

    public void execute(String url, Map<String, String> headers, String body, boolean post, NimHttpCallback callback) {
        if (!inited) {
            return;
        }
        executor.execute(new NimHttpTask(url, headers, body, callback, post));
    }


    public void release() {
        if (executor != null) {
            executor.shutdown();
        }
        if (connManager != null) {
            connManager.shutdown();
        }
        client = null;
        inited = false;
    }


    private String post(String url, Map<String, String> headers, String body) {
        HttpResponse response;
        HttpPost request;
        try {
            request = new HttpPost(url);

            // add request headers
            request.addHeader("charset", "utf-8");
            if (headers != null) {
                for (Map.Entry<String, String> header : headers.entrySet()) {
                    request.addHeader(header.getKey(), header.getValue());
                }
            }

            // add body
            HttpEntity entity = null;
            if (body != null) {
                entity = new StringEntity(body, HTTP.UTF_8);
            }

            if (entity != null) {
                request.setEntity(entity);
            }

            // execute
            response = client.execute(request);

            // response
            StatusLine statusLine = response.getStatusLine();
            if (statusLine == null) {
                Log.e(TAG, "http post response statusLine is null");
                throw new NimHttpException(NimHttpException.HTTP_EXCEPTION_RESPONSE_STATUS_LINE_NULL);
            }
            int statusCode = statusLine.getStatusCode();
            if (statusCode < 200 || statusCode > 299) {
                throw new NimHttpException(statusCode);
            }
            return EntityUtils.toString(response.getEntity(), "utf-8");
        } catch (Exception e) {
            Log.e(TAG, "http post data error=" + e.getMessage());
            Log.e(TAG, "error url = " + url);
            if (e instanceof NimHttpException) {
                throw (NimHttpException) e;
            } else if (e instanceof UnknownHostException) {
                throw new NimHttpException(408);
            }

            throw new NimHttpException(e);
        }
    }

    private String get(String url, Map<String, String> headers) {
        HttpResponse response;
        HttpGet request;
        try {
            request = new HttpGet(url);

            // add request headers
            request.addHeader("charset", "utf-8");
            if (headers != null) {
                for (Map.Entry<String, String> header : headers.entrySet()) {
                    request.addHeader(header.getKey(), header.getValue());
                }
            }

            // execute
            response = client.execute(request);

            // response
            StatusLine statusLine = response.getStatusLine();
            if (statusLine == null) {
                Log.e(TAG, "http get response statusLine is null");
                throw new NimHttpException(NimHttpException.HTTP_EXCEPTION_RESPONSE_STATUS_LINE_NULL);
            }
            int statusCode = statusLine.getStatusCode();
            if (statusCode < 200 || statusCode > 299) {
                throw new NimHttpException(statusCode);
            }
            return EntityUtils.toString(response.getEntity(), "utf-8");
        } catch (Exception e) {
            Log.e(TAG, "http get data error=" + e.getMessage());

            if (e instanceof NimHttpException) {
                throw (NimHttpException) e;
            } else if (e instanceof UnknownHostException) {
                throw new NimHttpException(408);
            }
            throw new NimHttpException(e);
        }
    }


    private static class InstanceHolder {
        private static final NimHttpClient INSTANCE = new NimHttpClient();
    }


    public class NimHttpTask implements Runnable {

        private String url;
        private Map<String, String> headers;
        private String jsonBody;
        private NimHttpCallback callback;
        private boolean post;

        public NimHttpTask(String url, Map<String, String> headers, String jsonBody, NimHttpCallback callback) {
            this(url, headers, jsonBody, callback, true);
        }

        public NimHttpTask(String url, Map<String, String> headers, String jsonBody, NimHttpCallback callback, boolean post) {
            this.url = url;
            this.headers = headers;
            this.jsonBody = jsonBody;
            this.callback = callback;
            this.post = post;
        }

        @Override
        public void run() {
            String response = null;
            int errorCode = 0;
            Logger.i("api: url = " + url +
                    " request = " + jsonBody);
            try {
                response = post ? post(url, headers, jsonBody) : get(url, headers);
            } catch (NimHttpException e) {
                errorCode = e.getHttpCode();
            } finally {
                final String res = response;
                final int code = errorCode;
                Logger.i("api: url = " + url
                        + " code = " + code
                        + " response = " + response);
                // do callback on ui thread
                uiHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (callback != null) {
                            callback.onResponse(res, code, null);
                        }
                    }
                });
            }
        }
    }


    /**
     * *********************** Http Task & BaseCallback *************************
     */
    public interface NimHttpCallback {
        void onResponse(String response, int code, String errorMsg);
    }
}
