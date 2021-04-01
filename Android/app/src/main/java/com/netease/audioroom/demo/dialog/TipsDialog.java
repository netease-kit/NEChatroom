package com.netease.audioroom.demo.dialog;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.TextView;

import com.netease.audioroom.demo.R;

import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

public class TipsDialog extends BaseDialogFragment {

    View mConentView;

    TextView tvContent;

    TextView tvTips;

    String content;

    public interface IClickListener {

        void onClick();
    }

    IClickListener clickListener;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(DialogFragment.STYLE_NO_TITLE, R.style.create_dialog_fragment);

    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        if (getDialog() == null) {
            dismiss();
        }
        getDialog().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        if (getArguments() != null) {
            content = getArguments().getString(TAG);
        }
        mConentView = inflater.inflate(R.layout.dialog_tips, container, false);
        return mConentView;
    }

    @Override
    public void onResume() {
        super.onResume();
        initView();
    }

    private void initView() {
        tvContent = mConentView.findViewById(R.id.content);
        tvTips = mConentView.findViewById(R.id.tips);
        if (!TextUtils.isEmpty(content)) {
            tvContent.setText(content);
        }
        getDialog().setOnKeyListener((dialog, keyCode, event) -> {
            if (keyCode == KeyEvent.KEYCODE_BACK) {
                return true;
            }
            return false;
        });
        tvTips.setOnClickListener(v -> clickListener.onClick());
    }


    public void setClickListener(IClickListener clickListener) {
        this.clickListener = clickListener;
    }


}
