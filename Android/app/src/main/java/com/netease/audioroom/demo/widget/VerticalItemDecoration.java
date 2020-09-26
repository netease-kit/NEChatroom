
package com.netease.audioroom.demo.widget;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import androidx.annotation.ColorInt;
import androidx.recyclerview.widget.RecyclerView;
import android.view.View;

/**
 * 垂直线性布局的RecyclerView分割线
 */
public class VerticalItemDecoration extends RecyclerView.ItemDecoration {


    private int color;
    private int dividerHeight;
    private Paint dividerPaint;
    private int leftMargin;
    private int rightMargin;


    /**
     * @param color         分割线颜色值
     * @param dividerHeight 分割线高度 px
     * @param leftMargin    分割线左边距
     * @param rightMargin   分割线右边距
     */
    public VerticalItemDecoration(@ColorInt int color, int dividerHeight, int leftMargin, int rightMargin) {
        this.color = color;
        this.dividerHeight = dividerHeight;
        this.leftMargin = leftMargin;
        this.rightMargin = rightMargin;

        dividerPaint = new Paint();
        dividerPaint.setStyle(Paint.Style.FILL);
        dividerPaint.setColor(color);
    }

    public VerticalItemDecoration(@ColorInt int color, int dividerHeight) {
        this(color, dividerHeight, 0, 0);
    }


    @Override
    public void onDraw(Canvas canvas, RecyclerView parent, RecyclerView.State state) {
        if (parent.getLayoutManager() == null || color == Color.TRANSPARENT) {
            return;
        }
        canvas.save();
        int childCount = parent.getChildCount();
        int left = parent.getPaddingLeft() + leftMargin;
        int right = parent.getWidth() - parent.getPaddingRight() - rightMargin;

        for (int i = 0; i < childCount - 1; i++) {
            View child = parent.getChildAt(i);
            float top = child.getBottom();
            float bottom = child.getBottom() + dividerHeight;
            canvas.drawRect(left, top, right, bottom, dividerPaint);
        }
        canvas.restore();
    }


    @Override
    public void getItemOffsets(Rect outRect,
                               View view,
                               RecyclerView parent,
                               RecyclerView.State state) {

        outRect.bottom = dividerHeight;
//        outRect.set(0, 0, 0, dividerHeight);
    }
}
