package com.netease.audioroom.demo.executor;


import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

public class NimTaskExecutor implements Executor {

    private final static int QUEUE_INIT_CAPACITY = 20;

    private final String name;
    private final Config config;
    private ExecutorService service;

    public NimTaskExecutor(String name, Config config) {
        this(name, config, true);
    }

    public NimTaskExecutor(String name, Config config, boolean startup) {
        this.name = name;
        this.config = config;

        if (startup) {
            startup();
        }
    }

    public void startup() {
        synchronized (this) {
            // has startup
            if (service != null && !service.isShutdown()) {
                return;
            }
            // create
            service = createExecutor(config);
        }
    }

    public void shutdown() {
        ExecutorService executor = null;

        synchronized (this) {
            // swap
            if (service != null) {
                executor = service;
                service = null;
            }
        }

        if (executor != null) {
            // shutdown
            if (!executor.isShutdown()) {
                executor.shutdown();
            }
        }
    }

    @Override
    public void execute(Runnable runnable) {
        synchronized (this) {
            // has shutdown, reject
            if (service == null || service.isShutdown()) {
                return;
            }
            // execute
            service.execute(runnable);
        }
    }

    public Future<?> submit(Runnable runnable) {
        synchronized (this) {
            if (service == null || service.isShutdown()) {
                return null;
            }
            return service.submit(runnable);
        }
    }

    private ExecutorService createExecutor(Config config) {
        ThreadPoolExecutor service = new ThreadPoolExecutor(config.core,
                config.max, config.timeout,
                TimeUnit.MILLISECONDS,
                new LinkedBlockingQueue<Runnable>(QUEUE_INIT_CAPACITY),
                new TaskThreadFactory(name),
                new ThreadPoolExecutor.DiscardPolicy());

        service.allowCoreThreadTimeOut(config.allowCoreTimeOut);
        return service;
    }


    private static class TaskThreadFactory implements ThreadFactory {

        private final ThreadGroup mThreadGroup;

        private final AtomicInteger mThreadNumber = new AtomicInteger(1);

        private final String mNamePrefix;

        TaskThreadFactory(String name) {
            SecurityManager securityManager = System.getSecurityManager();

            mThreadGroup = (securityManager != null) ? securityManager.getThreadGroup() : Thread.currentThread().getThreadGroup();

            mNamePrefix = name + "#";
        }

        public Thread newThread(Runnable runnable) {
            Thread thread = new Thread(mThreadGroup, runnable, mNamePrefix + mThreadNumber.getAndIncrement(), 0);

            // no daemon
            if (thread.isDaemon())
                thread.setDaemon(false);

            // normal priority
            if (thread.getPriority() != Thread.NORM_PRIORITY) {
                thread.setPriority(Thread.NORM_PRIORITY);
            }

            return thread;
        }
    }


    public static class Config {
        public final int core;
        public final int max;
        public final int timeout;
        public final boolean allowCoreTimeOut;

        public Config(int core, int max, int timeout, boolean allowCoreTimeOut) {
            this.core = core;
            this.max = max;
            this.timeout = timeout;
            this.allowCoreTimeOut = allowCoreTimeOut;
        }
    }

}