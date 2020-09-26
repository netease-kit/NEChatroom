package com.netease.audioroom.demo.config;

final class ServerConfig {

    public enum ServerEnv {
        TEST("t"),
        REL("r"),
        ;
        String tag;

        ServerEnv(String tag) {
            this.tag = tag;
        }
    }

    public static boolean testServer() {
        return ServerEnvs.SERVER == ServerEnv.TEST;
    }
}
