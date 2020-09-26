package com.netease.audioroom.demo.config;

/**
 * 云信Demo应用服务器地址（第三方APP请不要使用）
 */
public class DemoServers {

    private static final String API_SERVER = "https://app.yunxin.163.com/appdemo/voicechat/";// 线上
//    private static final String API_SERVER_TEST = "http://apptest.netease.im:8080/appdemo/voicechat/";// 测试
    private static final String API_SERVER_TEST = "https://apptest.netease.im/appdemo/voicechat/";// 测试

    public static final String audioRoomAPIServer() {
        return ServerConfig.testServer() ? API_SERVER_TEST : API_SERVER;
    }

}
