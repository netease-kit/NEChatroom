package com.netease.yunxin.nertc.nertcvoiceroom.model.ktv;

import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

/**
 * 已点歌词本地记录(单例)
 */
public class LyricList {

    private static final String LOG_TAG = LyricList.class.getSimpleName();

    private ReadWriteLock rwlock = new ReentrantReadWriteLock();

    private ConcurrentHashMap<String,List<Lrc>> lyricMap;

    static final class MusicOrderListHolder{
        public static final LyricList instance = new LyricList();
    }

    public static LyricList getInstance(){
        return MusicOrderListHolder.instance;
    }

    private LyricList(){
        lyricMap = new ConcurrentHashMap<>();
    }

    public void addLyric(MusicOrderedItem music, List<Lrc> lrcs){
        lyricMap.put(music.musicId,lrcs);
    }

    public List<Lrc> getLyric(MusicOrderedItem music){
        List<Lrc> lrcs = lyricMap.get(music.getKey());
        return lrcs;

    }



}
