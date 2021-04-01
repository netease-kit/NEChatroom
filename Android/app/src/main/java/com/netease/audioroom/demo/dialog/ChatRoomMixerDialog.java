package com.netease.audioroom.demo.dialog;

import android.app.Activity;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.SwitchCompat;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.widget.VolumeSetup;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoom;

/**
 * Created by luc on 1/28/21.
 */
public class ChatRoomMixerDialog extends BottomBaseDialog {

    private final NERtcVoiceRoom voiceRoom;

    private boolean isKtvModel;

    public ChatRoomMixerDialog(@NonNull Activity activity, NERtcVoiceRoom voiceRoom, boolean isKtvModel) {
        super(activity);
        this.voiceRoom = voiceRoom;
        this.isKtvModel = isKtvModel;
    }

    @Override
    protected void renderTopView(FrameLayout parent) {
        TextView titleView = new TextView(getContext());
        titleView.setText("调音台");
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
        titleView.setGravity(Gravity.CENTER);
        titleView.setTextColor(Color.parseColor("#ff333333"));
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        parent.addView(titleView, layoutParams);
    }

    @Override
    protected void renderBottomView(FrameLayout parent) {
        View bottomView = LayoutInflater.from(getContext()).inflate(R.layout.view_dialog_more_mixer, parent);

        SwitchCompat earBackSwitch = bottomView.findViewById(R.id.ear_back);
        earBackSwitch.setChecked(voiceRoom.isEarBackEnable());
        earBackSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> voiceRoom.enableEarback(isChecked));

        SeekBar skRecordingVolume = bottomView.findViewById(R.id.recording_volume_control);
        skRecordingVolume.setProgress(voiceRoom.getAudioCaptureVolume());
        skRecordingVolume.setOnSeekBarChangeListener(new VolumeSetup() {
            @Override
            protected void onVolume(int volume) {
                voiceRoom.setAudioCaptureVolume(volume);
            }
        });
        TextView tvMixer = bottomView.findViewById(R.id.tv_mixer);
        SeekBar sbMixer = bottomView.findViewById(R.id.sb_mixer);
        if (isKtvModel) {
            tvMixer.setVisibility(View.VISIBLE);
            sbMixer.setVisibility(View.VISIBLE);
            sbMixer.setProgress(voiceRoom.getAudioPlay().getMixingVolume(true));
            sbMixer.setOnSeekBarChangeListener(new VolumeSetup() {
                @Override
                protected void onVolume(int volume) {
                    voiceRoom.getAudioPlay().setMixingVolume(volume, true);
                }
            });
        } else {
            tvMixer.setVisibility(View.GONE);
            sbMixer.setVisibility(View.GONE);
        }
    }
}
