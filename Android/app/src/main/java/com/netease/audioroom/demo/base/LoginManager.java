package com.netease.audioroom.demo.base;

import android.util.Log;

import com.netease.audioroom.demo.base.action.ILoginAction;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.http.ChatRoomHttpClient;
import com.netease.audioroom.demo.model.AccountInfo;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.auth.AuthService;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.orhanobut.logger.Logger;

public class LoginManager implements ILoginAction {
    private static final String TAG = "LoginManager";
    private static LoginManager instance = new LoginManager();

    private LoginManager() {

    }

    public static LoginManager getInstance() {
        return instance;
    }


    public interface Callback {
        void onSuccess(AccountInfo accountInfo);

        void onFailed(int code, String errorMsg);
    }

    private Callback callback;

    @Override
    public void tryLogin() {
        final AccountInfo accountInfo = DemoCache.getAccountInfo();
        if (accountInfo == null) {
            fetchLoginAccount(null);
            return;
        }
        Logger.i("nim login:" +
                " account = " + accountInfo.account
                + " token = " + accountInfo.token);
        LoginInfo loginInfo = new LoginInfo(accountInfo.account, accountInfo.token);
        //服务器
        NIMClient.getService(AuthService.class).login(loginInfo).setCallback(new RequestCallback() {
            @Override
            public void onSuccess(Object o) {
                Logger.i("nim login success");
                afterLogin(accountInfo);
                callback.onSuccess(accountInfo);
            }

            @Override
            public void onFailed(int i) {
                Logger.i("nim login failed:"
                        + " code = " + i);
                fetchLoginAccount(accountInfo.account);

            }

            @Override
            public void onException(Throwable throwable) {
                fetchLoginAccount(accountInfo.account);

            }
        });
    }

    private void fetchLoginAccount(String preAccount) {
        ChatRoomHttpClient.getInstance().fetchAccount(preAccount, new ChatRoomHttpClient.ChatRoomHttpCallback<AccountInfo>() {
            @Override
            public void onSuccess(AccountInfo accountInfo) {
                login(accountInfo);

            }

            @Override
            public void onFailed(int code, String errorMsg) {
                ToastHelper.showToast("获取登录帐号失败 ， code = " + code);
                callback.onFailed(code, errorMsg);
            }
        });
    }


    private void login(final AccountInfo accountInfo) {
        Logger.i("nim login:" +
                " account = " + accountInfo.account
                + " token = " + accountInfo.token);
        LoginInfo loginInfo = new LoginInfo(accountInfo.account, accountInfo.token);
        NIMClient.getService(AuthService.class).login(loginInfo).setCallback(new RequestCallback() {
            @Override
            public void onSuccess(Object o) {
                Logger.i("nim login success");
                afterLogin(accountInfo);
                callback.onSuccess(accountInfo);
            }

            @Override
            public void onFailed(int i) {
                Logger.i("nim login failed:"
                        + " code = " + i);
                callback.onFailed(i, "SDK登录失败");
                ToastHelper.showToast("SDK登录失败 , code = " + i);
            }

            @Override
            public void onException(Throwable throwable) {
                ToastHelper.showToast("SDK登录异常 , e = " + throwable);
                callback.onFailed(throwable.hashCode(), "SDK登录异常");
            }
        });
    }


    private void afterLogin(AccountInfo accountInfo) {
        DemoCache.setAccountId(accountInfo.account);
        DemoCache.saveAccountInfo(accountInfo);
        Log.i(TAG, "after login  , account = " + accountInfo.account + " , nick = " + accountInfo.nick);
    }

    public void setCallback(Callback callback) {
        this.callback = callback;
    }

}
