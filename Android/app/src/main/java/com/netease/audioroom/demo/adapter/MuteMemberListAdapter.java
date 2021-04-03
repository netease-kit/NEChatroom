package com.netease.audioroom.demo.adapter;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.daimajia.swipe.SwipeLayout;
import com.daimajia.swipe.adapters.RecyclerSwipeAdapter;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.widget.HeadImageView;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;

import java.util.ArrayList;
import java.util.List;

public class MuteMemberListAdapter extends RecyclerSwipeAdapter<MuteMemberListAdapter.MuteMemberViewHolder> {
    private static final int TYPE_EMPTY = 1;
    private static final int TYPE_NORMAL = 2;

    private final Context context;
    private final List<VoiceRoomUser> members = new ArrayList<>();

    public interface IRemoveMute {
        void remove(int position);
    }

    IRemoveMute removeMute;

    public MuteMemberListAdapter(Context context) {
        this.context = context;
    }

    public void updateDataSource(List<VoiceRoomUser> members) {
        if (members == null) {
            return;
        }
        this.members.clear();
        this.members.addAll(members);
        notifyDataSetChanged();
    }

    public void removeItem(int index) {
        if (members.size() <= index) {
            return;
        }
        members.remove(index);
        notifyDataSetChanged();
    }

    @Override
    public int getItemCount() {
        return members.isEmpty() ? 1 : members.size();
    }

    @Override
    public int getSwipeLayoutResourceId(int position) {
        return position;
    }

    @Override
    public MuteMemberViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        int layoutId;
        boolean needInit;
        if (viewType == TYPE_EMPTY) {
            layoutId = R.layout.view_item_dialog_members_empty;
            needInit = false;
        } else {
            layoutId = R.layout.item_mute_swipe;
            needInit = true;
        }
        return new MuteMemberViewHolder(LayoutInflater.from(context).inflate(layoutId, parent, false), needInit);


    }

    @Override
    public int getItemViewType(int position) {
        return members.isEmpty() ? TYPE_EMPTY : TYPE_NORMAL;
    }

    @Override
    public void onBindViewHolder(MuteMemberViewHolder viewHolder, int position) {
        if (getItemViewType(position) == TYPE_EMPTY) {
            return;
        }

        viewHolder.swipeLayout.setShowMode(SwipeLayout.ShowMode.LayDown);
        viewHolder.linearLayout.setOnClickListener(v -> removeMute.remove(position));
        viewHolder.name.setText(members.get(position).getNick());
        viewHolder.headImageView.loadAvatar(members.get(position).getAvatar());
    }

    public static class MuteMemberViewHolder extends RecyclerView.ViewHolder {
        SwipeLayout swipeLayout;
        LinearLayout linearLayout;
        HeadImageView headImageView;
        TextView name;

        public MuteMemberViewHolder(@NonNull View itemView, boolean needInit) {
            super(itemView);
            if (!needInit) {
                return;
            }
            swipeLayout = itemView.findViewById(R.id.swipeLayout);
            linearLayout = itemView.findViewById(R.id.bottom_wrapper);
            headImageView = itemView.findViewById(R.id.memberinfo).findViewById(R.id.headview);
            name = itemView.findViewById(R.id.memberinfo).findViewById(R.id.chatroom_name);
        }
    }

    public void setRemoveMute(IRemoveMute removeMute) {
        this.removeMute = removeMute;
    }
}

