package com.netease.audioroom.demo.dialog;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.netease.audioroom.demo.R;

import androidx.annotation.NonNull;

/**
 * Created by luc on 1/20/21.
 */
public class RoomTypeChooserDialog extends BottomBaseDialog {
    private final OnItemClickListener onItemClickListener;

    public RoomTypeChooserDialog(@NonNull Activity activity, OnItemClickListener onItemClickListener) {
        super(activity);
        this.onItemClickListener = onItemClickListener;
    }

    @Override
    protected void renderTopView(FrameLayout parent) {
        TextView titleView = new TextView(getContext());
        titleView.setText("方案选择");
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
        titleView.setGravity(Gravity.CENTER);
        titleView.setTextColor(Color.parseColor("#ff222222"));
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        parent.addView(titleView, layoutParams);
    }

    @Override
    protected void renderBottomView(FrameLayout parent) {
        LayoutInflater.from(getContext()).inflate(R.layout.dialog_room_type_bottom, parent);
        View rtc = parent.findViewById(R.id.room_type_txt_rtc);
        rtc.setOnClickListener(v -> {
            if (onItemClickListener != null) {
                onItemClickListener.onItemClicked(activity, 1);
            }
            doDismiss();
        });

        View cdn = parent.findViewById(R.id.room_type_txt_cdn);
        cdn.setOnClickListener(v -> {
            if (onItemClickListener != null) {
                onItemClickListener.onItemClicked(activity, 0);
            }
            doDismiss();
        });

        View cancel = parent.findViewById(R.id.room_type_cancel);
        cancel.setOnClickListener(v -> {
            doDismiss();
        });
    }

    private void doDismiss() {
        if (!isShowing()) {
            return;
        }
        try {
            dismiss();
        } catch (WindowManager.BadTokenException exception) {
            exception.printStackTrace();
        }
    }


    public interface OnItemClickListener {
        /**
         * 弹窗条目点击类型 type：1 rtc, 0 cdn
         */
        void onItemClicked(Context context, int type);
    }
}
