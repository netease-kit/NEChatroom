package com.netease.audioroom.demo.dialog;

import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.gyf.immersionbar.ImmersionBar;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.util.IconFontUtil;

public class NoticeDialog extends BaseDialogFragment {

    View contentView;

    TextView close;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(DialogFragment.STYLE_NO_TITLE, R.style.request_dialog_fragment);

    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        if (getDialog() == null) {
            dismiss();
        }
        getDialog().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        contentView = inflater.inflate(R.layout.dialog_notice_layout, container, false);
        return contentView;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        ImmersionBar.with(this).statusBarDarkFont(false).init();
    }

    @Override
    public void onResume() {
        super.onResume();
        initView();
    }

    private void initView() {
        close = contentView.findViewById(R.id.close);
        IconFontUtil.getInstance().setFontText(close, IconFontUtil.CLOSE);
        close.setOnClickListener(v -> dismiss());
        getDialog().setOnKeyListener((dialog, keyCode, event) -> {
            if (keyCode == KeyEvent.KEYCODE_BACK) {
                return true;
            }
            return false;
        });
    }
}
