// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.gift;

import android.animation.Animator;
import android.view.View;
import com.airbnb.lottie.LottieAnimationView;
import com.netease.yunxin.kit.alog.ALog;
import java.util.LinkedList;
import java.util.Queue;

public class GiftRender {
  private static final String TAG = "GiftRender";
  private final Queue<Integer> giftQueue = new LinkedList<>();
  private LottieAnimationView animationView = null;
  private boolean isAnimating = false;

  public void init(LottieAnimationView animationView) {
    this.animationView = animationView;
    this.animationView.addAnimatorListener(
        new Animator.AnimatorListener() {

          @Override
          public void onAnimationStart(Animator animation) {
            ALog.d(TAG, "onAnimationStart");
          }

          @Override
          public void onAnimationEnd(Animator animation) {
            ALog.d(TAG, "onAnimationEnd");
            animationView.setVisibility(View.GONE);
            if (!giftQueue.isEmpty()) {
              playAnim(giftQueue.poll());
            } else {
              isAnimating = false;
            }
          }

          @Override
          public void onAnimationCancel(Animator animation) {
            ALog.d(TAG, "onAnimationCancel");
            isAnimating = !giftQueue.isEmpty();
          }

          @Override
          public void onAnimationRepeat(Animator animation) {
            ALog.d(TAG, "onAnimationRepeat");
          }
        });
  }

  public void addGift(int gitResId) {
    ALog.d(TAG, "addGift,gitResId:" + gitResId);
    giftQueue.add(gitResId);
    if (!isAnimating) {
      isAnimating = true;
      playAnim(giftQueue.poll());
    }
  }

  public void release() {
    ALog.d(TAG, "release");
    giftQueue.clear();
    if (animationView != null) {
      animationView.cancelAnimation();
      animationView.setVisibility(View.GONE);
    }
  }

  private void playAnim(int gitResId) {
    if (gitResId == 0) {
      return;
    }
    if (animationView != null) {
      animationView.setVisibility(View.VISIBLE);
      animationView.setAnimation(gitResId);
      ALog.d(TAG, "playAnim,gitResId:" + gitResId);
      animationView.playAnimation();
    }
  }
}
