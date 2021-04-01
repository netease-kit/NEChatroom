package com.netease.audioroom.demo.util;

import android.view.View;

/**
 * Created by luc on 2020/11/25.
 */
public final class ViewUtils {

    /**
     * 判断当前坐标是否在设置的view上
     *
     * @param view 目标 view
     * @param x    横坐标
     * @param y    纵坐标
     * @return true 在view 上，false 反之。
     */
    public static boolean isInView(View view, int x, int y) {
        if (view == null) {
            return false;
        }
        int[] location = new int[2];
        view.getLocationOnScreen(location);
        int left = location[0];
        int top = location[1];
        int right = left + view.getMeasuredWidth();
        int bottom = top + view.getMeasuredHeight();
        return y >= top && y <= bottom && x >= left
                && x <= right;
    }
}
