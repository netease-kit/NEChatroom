package com.netease.audioroom.demo.http;


public class NimHttpException extends RuntimeException {

    public static final int HTTP_EXCEPTION_RESPONSE_STATUS_LINE_NULL = -2;
    public static final int HTTP_EXCEPTION_UNKNOWN = -1;

    private static final long serialVersionUID = -3537304844268409258L;

    private final int httpCode;

    public int getHttpCode() {
        return httpCode;
    }

    public NimHttpException(Throwable e) {
        super(e);
        this.httpCode = HTTP_EXCEPTION_UNKNOWN;
    }

    public NimHttpException(int httpCode) {
        super();
        this.httpCode = httpCode;
    }

    public NimHttpException() {
        this(HTTP_EXCEPTION_UNKNOWN);
    }
}