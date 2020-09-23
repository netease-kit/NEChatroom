package com.netease.audioroom.demo.dialog;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentTransaction;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.activity.AnchorActivity;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.http.ChatRoomHttpClient;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.audioroom.demo.util.Network;
import com.netease.audioroom.demo.util.NetworkChange;
import com.netease.audioroom.demo.util.NetworkUtils;
import com.netease.audioroom.demo.util.NetworkWatcher;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef;

import java.util.Observable;

public class CreateRoomNameDialog extends BaseDialogFragment {


    private View mContextView;
    private EditText mEditText;
    private Button mBtnCancel;
    private Button mBtnCreateRoom;

    private View mRootView, mLoading;

    private boolean hasNet = true;

    private final static String AUDIO_QUALITY = "audio_quality";

    private int audioQuality;

    public static CreateRoomNameDialog newInstance(int audioQuality) {
        CreateRoomNameDialog dialog = new CreateRoomNameDialog();
        Bundle arg = new Bundle();
        arg.putInt(AUDIO_QUALITY, audioQuality);
        dialog.setArguments(arg);
        return dialog;
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(android.app.DialogFragment.STYLE_NO_TITLE, R.style.create_dialog_fragment);

    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        getDialog().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        mContextView = inflater.inflate(R.layout.dialog_creater_roomname, container, false);
        audioQuality = getArguments().getInt(AUDIO_QUALITY, NERtcVoiceRoomDef.RoomAudioQuality.DEFAULT_QUALITY);
        return mContextView;
    }

    @Override
    public void onStart() {
        super.onStart();
        initView();
        initListener();
    }

    @Override
    public void onResume() {
        super.onResume();
        NetworkWatcher watcher = new NetworkWatcher() {
            @Override
            public void update(Observable observable, Object data) {
                super.update(observable, data);
                Network network = (Network) data;
                hasNet = network.isConnected();
            }
        };

        NetworkChange.getInstance().addObserver(watcher);
    }

    private void initView() {
        mEditText = mContextView.findViewById(R.id.eturl);
        mBtnCancel = mContextView.findViewById(R.id.btnCancal);
        mBtnCreateRoom = mContextView.findViewById(R.id.btnCreaterRoom);
        mRootView = mContextView.findViewById(R.id.root);
        mLoading = mContextView.findViewById(R.id.loadingview);
        mBtnCreateRoom.setEnabled(false);

    }

    @Override
    public int show(FragmentTransaction transaction, String tag) {
        return super.show(transaction, tag);
    }

    private void initListener() {
        mEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                if (!TextUtils.isEmpty(s)) {
                    mBtnCreateRoom.setEnabled(true);
                    mBtnCreateRoom.setTextColor(getContext().getResources().getColor(R.color.color_2799ff));
                } else {
                    mBtnCreateRoom.setEnabled(false);
                    mBtnCreateRoom.setTextColor(getContext().getResources().getColor(R.color.color_8fb5e1));
                }
            }
        });
        mBtnCancel.setOnClickListener((v) -> dismiss());
        mBtnCreateRoom.setOnClickListener((v) -> {
            if (!hasNet) {
                ToastHelper.showToast(" 请检查你的网络");
            } else {
                mBtnCreateRoom.setEnabled(false);
                updateLoadingUI(true);
                createRoom(mEditText.getText().toString());
            }

        });
    }


    //创建房间
    private void createRoom(String roomName) {
        ChatRoomHttpClient.getInstance().createRoom(DemoCache.getAccountId(), roomName,
                new ChatRoomHttpClient.ChatRoomHttpCallback<VoiceRoomInfo>() {
                    @Override
                    public void onSuccess(VoiceRoomInfo roomInfo) {
                        updateLoadingUI(false);
                        if (roomInfo != null) {
                            roomInfo.setAudioQuality(audioQuality);
                            AnchorActivity.start(getContext(), roomInfo);
                            dismiss();
                            hideSoftInput();
                        } else {
                            ToastHelper.showToast("创建房间失败，返回信息为空");
                        }
                    }

                    @Override
                    public void onFailed(int code, String errorMsg) {
                        mBtnCreateRoom.setEnabled(true);
                        if (TextUtils.isEmpty(errorMsg)) {
                            errorMsg = "参数错误";
                        }
                        ToastHelper.showToast("创建失败:" + (!NetworkUtils.isNetworkConnected(getContext()) ? "网络错误" : errorMsg));
                        dismiss();
                    }
                });
    }

    private void hideSoftInput() {
        InputMethodManager imm = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(mEditText.getWindowToken(), 0);
    }


    private void updateLoadingUI(boolean isLoading) {
        mLoading.setVisibility(isLoading ? View.VISIBLE : View.GONE);
        mRootView.setVisibility(isLoading ? View.INVISIBLE : View.VISIBLE);
        mBtnCreateRoom.setEnabled(!isLoading);
    }

    @Override
    public void onDismiss(DialogInterface dialog) {
        NetworkChange.getInstance().deleteObservers();
        super.onDismiss(dialog);

    }
}
