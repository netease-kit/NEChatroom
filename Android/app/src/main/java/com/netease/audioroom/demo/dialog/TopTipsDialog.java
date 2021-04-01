package com.netease.audioroom.demo.dialog;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.Html;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.gyf.immersionbar.ImmersionBar;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.util.ScreenUtil;

import androidx.annotation.ColorInt;
import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

public class TopTipsDialog extends BaseDialogFragment {

    View view;

    TextView content;

    LinearLayout linearLayout;

    Style style;

    public interface IClickListener {

        void onClick();
    }

    IClickListener clickListener;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(DialogFragment.STYLE_NO_TITLE, R.style.request_dialog_fragment);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        Bundle bundle = getArguments();
        if (bundle != null) {
            style = getArguments().getParcelable(TAG);
        } else {
            dismiss();
        }
        view = inflater.inflate(R.layout.dialog_top_tips, container, false);
        // 设置宽度为屏宽、靠近屏幕底部。
        Window window = getDialog().getWindow();
        //window.setBackgroundDrawableResource(R.color.color_00000000);
        WindowManager.LayoutParams wlp = window.getAttributes();
        wlp.gravity = Gravity.TOP;
        wlp.width = WindowManager.LayoutParams.MATCH_PARENT;
        wlp.height = WindowManager.LayoutParams.WRAP_CONTENT;
        window.setAttributes(wlp);
        return view;
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
        content = view.findViewById(R.id.content);
        linearLayout = view.findViewById(R.id.root);
        if (!TextUtils.isEmpty(style.getTips())) {
            content.setText(Html.fromHtml(style.getTips()));
        }
        if (style.getTipIcon() != 0) {
            Drawable drawable = getResources().getDrawable(style.getTipIcon());
            drawable.setBounds(0, 0, drawable.getMinimumWidth(), drawable.getMinimumHeight());
            content.setCompoundDrawables(drawable, null, null, null);
            content.setCompoundDrawablePadding(ScreenUtil.dip2px(content.getContext(),4));
        }
        if (style.getBackground() != 0) {
            linearLayout.setBackgroundColor(getResources().getColor(style.getBackground()));
        }
        if (style.getTextColor() != 0) {
            content.setTextColor(getResources().getColor(style.getTextColor()));
        }
        getDialog().setOnKeyListener((dialog, keyCode, event) -> {
            if (keyCode == KeyEvent.KEYCODE_BACK) {
                return true;
            }
            return false;
        });
        content.setOnClickListener(v -> {
            if (clickListener != null) {
                clickListener.onClick();
            }
        });
    }


    public void setClickListener(IClickListener clickListener) {
        this.clickListener = clickListener;
    }

    public TextView getContent() {
        return content;
    }


    public class Style implements Parcelable {

        String tips;

        @ColorInt int background;

        @DrawableRes int tipIcon;

        @ColorInt int textColor;

        public Style(String tips, int background, int tipIcon, int textColor) {
            this.tips = tips;
            this.background = background;
            this.tipIcon = tipIcon;
            this.textColor = textColor;
        }


        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeString(this.tips);
            dest.writeInt(this.background);
            dest.writeInt(this.tipIcon);
            dest.writeInt(this.textColor);
        }

        protected Style(Parcel in) {
            this.tips = in.readString();
            this.background = in.readInt();
            this.tipIcon = in.readInt();
            this.textColor = in.readInt();
        }

        public final Creator<Style> CREATOR = new Creator<Style>() {

            @Override
            public Style createFromParcel(Parcel source) {
                return new Style(source);
            }

            @Override
            public Style[] newArray(int size) {
                return new Style[size];
            }
        };

        public String getTips() {
            return tips;
        }

        public int getBackground() {
            return background;
        }

        public int getTipIcon() {
            return tipIcon;
        }

        public int getTextColor() {
            return textColor;
        }
    }
}
