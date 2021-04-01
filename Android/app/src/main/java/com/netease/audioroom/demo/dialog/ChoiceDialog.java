package com.netease.audioroom.demo.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.TextView;

import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;

import com.netease.yunxin.kit.alog.ALog;
import com.netease.audioroom.demo.R;

/**
 * Created by luc on 2020/12/3.
 * 选择dialog
 */
public class ChoiceDialog extends Dialog {
    protected Activity activity;
    protected View rootView;

    protected String titleStr;
    protected String contentStr;
    protected String positiveStr;
    protected String negativeStr;

    protected boolean enableTitle = true;

    protected View.OnClickListener positiveListener;
    protected View.OnClickListener negativeListener;


    public ChoiceDialog(@NonNull Activity activity) {
        super(activity, R.style.CommonDialog);
        this.activity = activity;
        rootView = LayoutInflater.from(getContext()).inflate(contentLayoutId(), null);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(rootView);
        //fix one plus not show when resume from background
        getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    protected @LayoutRes
    int contentLayoutId() {
        return R.layout.view_dialog_choice_layout;
    }

    /**
     * 页面渲染
     */
    protected void renderRootView(View rootView) {
        if (rootView == null) {
            return;
        }
        TextView tvTitle = rootView.findViewById(R.id.tv_dialog_title);
        tvTitle.setText(titleStr);
        tvTitle.setVisibility(enableTitle ? View.VISIBLE : View.GONE);

        TextView tvContent = rootView.findViewById(R.id.tv_dialog_content);
        tvContent.setText(contentStr);

        TextView tvPositive = rootView.findViewById(R.id.tv_dialog_positive);
        tvPositive.setText(positiveStr);
        tvPositive.setOnClickListener(v -> {
            dismiss();
            if (positiveListener != null) {
                positiveListener.onClick(v);
            }
        });

        TextView tvNegative = rootView.findViewById(R.id.tv_dialog_negative);
        tvNegative.setText(negativeStr);
        tvNegative.setOnClickListener(v -> {
            dismiss();
            if (negativeListener != null) {
                negativeListener.onClick(v);
            }
        });

    }

    public ChoiceDialog setTitle(String title) {
        this.titleStr = title;
        return this;
    }

    public ChoiceDialog enableTitle(boolean enable) {
        this.enableTitle = enable;
        return this;
    }

    public ChoiceDialog setContent(String content) {
        this.contentStr = content;
        return this;
    }

    public ChoiceDialog setPositive(String positive, View.OnClickListener listener) {
        this.positiveStr = positive;
        this.positiveListener = listener;
        return this;
    }

    public ChoiceDialog setNegative(String negative, View.OnClickListener listener) {
        this.negativeListener = listener;
        this.negativeStr = negative;
        return this;
    }

    @Override
    public void show() {
        if (isShowing()) {
            return;
        }
        renderRootView(rootView);
        try {
            super.show();
        } catch (WindowManager.BadTokenException e) {
            ALog.e("ChoiceDialog", "error message is :" + e.getMessage());
        }
    }
}
