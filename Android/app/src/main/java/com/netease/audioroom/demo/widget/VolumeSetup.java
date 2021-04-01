package com.netease.audioroom.demo.widget;

import android.widget.SeekBar;

/**
 * Created by luc on 1/28/21.
 */
public class VolumeSetup implements SeekBar.OnSeekBarChangeListener {
    protected void onVolume(int volume) {

    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        if (fromUser) {
            onVolume(progress);
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }
}
