package com.netease.audioroom.demo.adapter;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.base.adapter.BaseAdapter;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Reason;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status;

import java.util.ArrayList;

public class SeatAdapter extends BaseAdapter<VoiceRoomSeat> {

    public SeatAdapter(ArrayList<VoiceRoomSeat> seats, Context context) {
        super(seats, context);

    }


    @Override
    protected RecyclerView.ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType) {
        return new SeatViewHolder(layoutInflater.inflate(R.layout.item_seat, parent, false));
    }

    @Override
    protected void onBindBaseViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        VoiceRoomSeat seat = getItem(position);
        if (seat == null) {
            return;
        }
        SeatViewHolder viewHolder = (SeatViewHolder) holder;
        int status = seat.getStatus();
        VoiceRoomUser user = seat.getUser();

        switch (status) {
            case Status.INIT:
                viewHolder.ivStatusHint.setVisibility(View.GONE);
                viewHolder.iv_user_status.setVisibility(View.VISIBLE);
                viewHolder.iv_user_status.setImageResource(R.drawable.seat_add_member);
                viewHolder.circle.setVisibility(View.INVISIBLE);
                break;
            case Status.APPLY:
                viewHolder.iv_user_status.setVisibility(View.VISIBLE);
                viewHolder.iv_user_status.setImageResource(R.drawable.threepoints);
                if (seat.getReason() != Reason.APPLY_MUTED) {
                    viewHolder.ivStatusHint.setVisibility(View.GONE);
                } else {
                    viewHolder.ivStatusHint.setVisibility(View.VISIBLE);
                    viewHolder.ivStatusHint.setImageResource(R.drawable.audio_be_muted_status);
                }
                viewHolder.tvNick.setText(user.getAccount());
                viewHolder.circle.setVisibility(View.INVISIBLE);
                break;

            case Status.ON:
                viewHolder.iv_user_status.setVisibility(View.GONE);
                viewHolder.ivStatusHint.setVisibility(View.GONE);
                viewHolder.circle.setVisibility(View.VISIBLE);
                break;
            case Status.CLOSED:
                viewHolder.iv_user_status.setVisibility(View.VISIBLE);
                viewHolder.ivStatusHint.setVisibility(View.GONE);
                viewHolder.iv_user_status.setImageResource(R.drawable.close);
                viewHolder.circle.setVisibility(View.INVISIBLE);
                break;
            case Status.FORBID:
                viewHolder.iv_user_status.setVisibility(View.VISIBLE);
                viewHolder.ivStatusHint.setVisibility(View.GONE);
                viewHolder.iv_user_status.setImageResource(R.drawable.seat_close);
                viewHolder.circle.setVisibility(View.INVISIBLE);
                break;
            case Status.AUDIO_MUTED:
                viewHolder.iv_user_status.setVisibility(View.GONE);
                viewHolder.ivStatusHint.setVisibility(View.VISIBLE);
                viewHolder.ivStatusHint.setImageResource(R.drawable.audio_be_muted_status);
                viewHolder.circle.setVisibility(View.INVISIBLE);
                break;
            case Status.AUDIO_CLOSED:
            case Status.AUDIO_CLOSED_AND_MUTED:
                viewHolder.iv_user_status.setVisibility(View.GONE);
                viewHolder.ivStatusHint.setVisibility(View.VISIBLE);
                viewHolder.ivStatusHint.setImageResource(R.drawable.close_audio_status);
                viewHolder.circle.setVisibility(View.INVISIBLE);
                break;
        }

        if (user != null && status == Status.APPLY) {//请求麦位
            viewHolder.tvNick.setText(user.getNick());
        } else if (seat.isOn()) {//麦上有人
            viewHolder.ivAvatar.loadAvatar(user.getAvatar());
            viewHolder.tvNick.setVisibility(View.VISIBLE);
            viewHolder.tvNick.setText(user.getNick());
        } else {
            viewHolder.tvNick.setText("麦位" + (seat.getIndex() + 1));
            viewHolder.circle.setVisibility(View.INVISIBLE);
        }

    }


}
