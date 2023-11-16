// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.widget;

import android.content.Context;
import android.view.View;
import android.widget.TextView;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.adapter.LiveBaseAdapter;
import java.util.List;

public class ChatMsgListAdapter extends LiveBaseAdapter<CharSequence> {

  public ChatMsgListAdapter(Context context, List<CharSequence> dataSource) {
    super(context, dataSource);
  }

  @Override
  protected int getLayoutId(int viewType) {
    return R.layout.item_msg_list;
  }

  @Override
  protected LiveViewHolder onCreateViewHolder(View itemView) {
    return new LiveViewHolder(itemView);
  }

  @Override
  protected void onBindViewHolder(LiveViewHolder holder, CharSequence itemData) {
    TextView tvContent = holder.getView(R.id.tv_chat_content);
    tvContent.setText(itemData);
  }

  void appendItem(CharSequence sequence) {
    if (sequence == null) {
      return;
    }
    dataSource.add(sequence);
    notifyItemInserted(dataSource.size() - 1);
  }

  void appendItems(List<CharSequence> sequenceList) {
    if (sequenceList == null || sequenceList.isEmpty()) {
      return;
    }
    int start = getItemCount();
    dataSource.addAll(sequenceList);
    notifyItemRangeInserted(start, sequenceList.size());
  }

  void clearAll() {
    dataSource.clear();
    notifyDataSetChanged();
  }
}
