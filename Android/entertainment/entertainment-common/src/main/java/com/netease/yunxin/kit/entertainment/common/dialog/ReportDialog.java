// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.dialog;

import android.annotation.SuppressLint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.kit.common.ui.dialog.BaseBottomDialog;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.entertainment.common.R;

public class ReportDialog extends BaseBottomDialog {
  public static final String TAG = "ReportDialog";

  @Nullable
  @Override
  protected View getRootView(
      @NonNull LayoutInflater layoutInflater, @Nullable ViewGroup viewGroup) {
    View bottomView =
        LayoutInflater.from(getContext())
            .inflate(R.layout.one_one_one_chat_dialog_report, viewGroup);
    bottomView.findViewById(R.id.tv_cancel).setOnClickListener(v -> dismiss());
    String[] reportContent = getContext().getResources().getStringArray(R.array.report_content);
    RecyclerView recyclerView = bottomView.findViewById(R.id.recyclerView);
    recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
    recyclerView.setAdapter(
        new RecyclerView.Adapter() {
          @NonNull
          @Override
          public RecyclerView.ViewHolder onCreateViewHolder(
              @NonNull ViewGroup parent, int viewType) {
            View view =
                LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.one_on_one_chat_item_report_content, parent, false);
            return new ContentViewHolder(view);
          }

          @Override
          public void onBindViewHolder(
              @NonNull RecyclerView.ViewHolder holder, @SuppressLint("RecyclerView") int position) {
            ContentViewHolder topicViewHolder = (ContentViewHolder) holder;
            String hotTopic = reportContent[position];
            topicViewHolder.tv.setText(hotTopic);
            topicViewHolder.itemView.setOnClickListener(
                v -> {
                  ToastUtils.INSTANCE.showShortToast(
                      getContext(), getString(R.string.one_one_one_report_success));
                  dismiss();
                });
          }

          @Override
          public int getItemCount() {
            return reportContent.length;
          }
        });
    return bottomView;
  }

  private static class ContentViewHolder extends RecyclerView.ViewHolder {
    private TextView tv;

    public ContentViewHolder(@NonNull View itemView) {
      super(itemView);
      tv = itemView.findViewById(R.id.tv);
    }
  }
}
