package com.netease.audioroom.demo.dialog;

import android.app.Activity;
import android.view.View;


import com.netease.audioroom.demo.R;

import androidx.annotation.NonNull;

/**
 * Created by luc on 2020/12/3.
 */
public class NotificationDialog extends ChoiceDialog {
    public NotificationDialog(@NonNull Activity activity) {
        super(activity);
        setCancelable(false);
    }

    @Override
    protected void renderRootView(View rootView) {
        super.renderRootView(rootView);
        rootView.findViewById(R.id.line_divide).setVisibility(View.GONE);
    }
}
