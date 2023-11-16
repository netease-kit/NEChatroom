// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewConfiguration;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public class ChatRoomMsgRecyclerView extends RecyclerView {
  private final Context context;
  private ChatMsgListAdapter chatMsgListAdapter;
  private LinearLayoutManager layoutManager;
  private boolean isTouching = false;
  private float lastX = 0f;
  private float lastY = 0f;
  private int touchSlop = 0;

  public ChatRoomMsgRecyclerView(@NonNull Context context) {
    super(context);
    this.context = context;
    init();
  }

  public ChatRoomMsgRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    this.context = context;
    init();
  }

  public ChatRoomMsgRecyclerView(
      @NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    this.context = context;
    init();
  }

  private void init() {
    chatMsgListAdapter = new ChatMsgListAdapter(context, new ArrayList());
    touchSlop = ViewConfiguration.get(context).getScaledTouchSlop();
    layoutManager = new LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false);
  }

  @Override
  protected void onAttachedToWindow() {
    super.onAttachedToWindow();
    setLayoutManager(layoutManager);
    setAdapter(chatMsgListAdapter);
  }

  @Override
  protected void onDetachedFromWindow() {
    super.onDetachedFromWindow();
    setLayoutManager(null);
    setAdapter(null);
  }

  public void appendItem(CharSequence sequence) {
    chatMsgListAdapter.appendItem(sequence);
    toLatestMsg();
  }

  public void appendItems(List<CharSequence> sequenceList) {
    chatMsgListAdapter.appendItems(sequenceList);
    toLatestMsg();
  }

  public void toLatestMsg() {
    if (!isTouching) {
      layoutManager.scrollToPosition(chatMsgListAdapter.getItemCount() - 1);
    }
  }

  void clearAllInfo() {
    chatMsgListAdapter.clearAll();
  }

  @Override
  public boolean dispatchTouchEvent(MotionEvent ev) {
    if (ev.getAction() == MotionEvent.ACTION_DOWN) {
      lastX = ev.getX();
      lastY = ev.getY();
      isTouching = true;
      getParent().requestDisallowInterceptTouchEvent(true);
    } else if (ev.getAction() == MotionEvent.ACTION_MOVE) {
      float currentX = ev.getX();
      float currentY = ev.getY();
      float resultX = currentX - lastX;
      float resultY = currentY - lastY;
      getParent()
          .requestDisallowInterceptTouchEvent(
              Math.abs(resultX) <= touchSlop || Math.abs(resultY) >= touchSlop);
    } else if (ev.getAction() == MotionEvent.ACTION_CANCEL
        || ev.getAction() == MotionEvent.ACTION_UP) {
      isTouching = false;
      getParent().requestDisallowInterceptTouchEvent(false);
    }

    return super.dispatchTouchEvent(ev);
  }
}
