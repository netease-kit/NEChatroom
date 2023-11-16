/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.kit.entertainment.common.floatplay

import android.animation.Animator
import android.animation.ValueAnimator
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.util.AttributeSet
import android.view.Gravity
import android.view.MotionEvent
import android.view.ViewConfiguration
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.FrameLayout
import com.netease.yunxin.kit.common.utils.ScreenUtils
import com.netease.yunxin.kit.common.utils.SizeUtils
import com.netease.yunxin.kit.entertainment.common.R
import kotlin.math.abs

/**
 * 悬浮窗组件
 */
class FloatView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {
    companion object {
        private const val TAG = "FloatView"
        private var lastClickTime: Long = 0
        private const val CLICK_TIME = 300 // 快速点击间隔时间
    }

    // 判断按钮是否快速点击
    fun isFastClick(): Boolean {
        val time = System.currentTimeMillis()
        if (time - lastClickTime < CLICK_TIME) { // 判断系统时间差是否小于点击间隔时间
            return true
        }
        lastClickTime = time
        return false
    }

    /**
     * 按下事件距离屏幕左边界的距离
     */
    private var mXDownInScreen = 0f

    /**
     * 按下事件距离屏幕上边界的距离
     */
    private var mYDownInScreen = 0f

    /**
     * 滑动事件距离屏幕左边界的距离
     */
    private var mXInScreen = 0f

    /**
     * 滑动事件距离屏幕上边界的距离
     */
    private var mYInScreen = 0f
    private var mWindowManager: WindowManager? = null
    private var mWindowParams: WindowManager.LayoutParams? = null
    private var windowParamsX = 0
    private var windowParamsY = 0
    private val animator = ValueAnimator.ofInt(0, 1).setDuration(100)
        .apply {
            interpolator = AccelerateDecelerateInterpolator()
        }
    init {
        initWindow()
    }

    private fun initWindow() {
        mWindowManager =
            context.applicationContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        mWindowParams = WindowManager.LayoutParams()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mWindowParams!!.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            mWindowParams!!.type = WindowManager.LayoutParams.TYPE_PHONE
        }
        mWindowParams!!.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
        mWindowParams!!.windowAnimations = R.style.FloatWindowAnimation
        mWindowParams!!.format = PixelFormat.TRANSLUCENT
        mWindowParams!!.gravity = Gravity.LEFT or Gravity.TOP
    }

    fun addToWindow(): Boolean {
        return if (mWindowManager != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                if (!isAttachedToWindow) {
                    mWindowManager!!.addView(this, mWindowParams)
                    true
                } else {
                    false
                }
            } else {
                try {
                    if (parent == null) {
                        mWindowManager!!.addView(this, mWindowParams)
                    }
                    true
                } catch (e: Exception) {
                    false
                }
            }
        } else {
            false
        }
    }

    fun removeFromWindow(): Boolean {
        return if (mWindowManager != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                if (isAttachedToWindow) {
                    mWindowManager!!.removeViewImmediate(this)
                    true
                } else {
                    false
                }
            } else {
                try {
                    if (parent != null) {
                        mWindowManager!!.removeViewImmediate(this)
                    }
                    true
                } catch (e: Exception) {
                    false
                }
            }
        } else {
            false
        }
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                if (animator.isRunning) {
                    animator.cancel()
                }
                mXDownInScreen = event.rawX
                mYDownInScreen = event.rawY
                mXInScreen = event.rawX
                mYInScreen = event.rawY
            }
            MotionEvent.ACTION_MOVE -> {
                val dx = (event.rawX - mXDownInScreen).toInt()
                val dy = (event.rawY - mYDownInScreen).toInt()
                val x = windowParamsX + dx
                val y = windowParamsY + dy
                mWindowParams!!.x = x
                mWindowParams!!.y = y
                windowParamsX = x
                windowParamsY = y
                mWindowManager!!.updateViewLayout(this, mWindowParams)
                mXDownInScreen = event.rawX
                mYDownInScreen = event.rawY
            }
            MotionEvent.ACTION_UP -> handleUpEvent(event)
            else -> {
            }
        }
        return true
    }

    private fun handleUpEvent(event: MotionEvent) {
        if (event.rawX < ScreenUtils.getDisplayWidth() / 2) {
            moveToEdge(windowParamsX, 0)
        } else {
            moveToEdge(windowParamsX, ScreenUtils.getDisplayWidth() - SizeUtils.dp2px(98f))
        }
        if (isOnClickEvent(event)) {
            if (!isFastClick() && onFloatViewClickListener != null) {
                onFloatViewClickListener!!.onClick()
            }
        }
    }

    /**
     * 是否为点击事件
     */
    private fun isOnClickEvent(event: MotionEvent): Boolean {
        val scaledTouchSlop = ViewConfiguration.get(context).scaledTouchSlop
        return (
            abs(event.rawX - mXInScreen) <= scaledTouchSlop &&
                abs(event.rawY - mYInScreen) <= scaledTouchSlop
            )
    }

    private fun moveToEdge(startPosition: Int, endPosition: Int) {
        animator.setIntValues(startPosition, endPosition)
        animator.addUpdateListener { animation ->
            animation?.let {
                val value = animation.animatedValue as Int
                mWindowParams!!.x = value
                mWindowManager!!.updateViewLayout(this@FloatView, mWindowParams)
            }
        }
        animator.addListener(object : Animator.AnimatorListener {
            override fun onAnimationStart(animation: Animator) {
            }

            override fun onAnimationEnd(animation: Animator) {
                animator.removeAllUpdateListeners()
                animator.removeAllListeners()
                windowParamsX = endPosition
            }

            override fun onAnimationCancel(animation: Animator) {
                animator.removeAllUpdateListeners()
                animator.removeAllListeners()
                windowParamsX = endPosition
            }

            override fun onAnimationRepeat(animation: Animator) {
            }
        })
        animator.start()
    }

    fun update(width: Int, height: Int) {
        mWindowParams!!.width = width
        mWindowParams!!.height = height
        mWindowManager!!.updateViewLayout(this, mWindowParams)
    }

    fun update(width: Int, height: Int, x: Int, y: Int) {
        mWindowParams!!.width = width
        mWindowParams!!.height = height
        mWindowParams!!.x = x
        mWindowParams!!.y = y
        windowParamsX = x
        windowParamsY = y
        mWindowManager!!.updateViewLayout(this, mWindowParams)
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        if (animator.isRunning) {
            animator.cancel()
        }
        animator.removeAllUpdateListeners()
        animator.removeAllListeners()
    }

    private var onFloatViewClickListener: OnFloatViewClickListener? = null
    fun setOnFloatViewClickListener(onFloatViewClickListener: OnFloatViewClickListener?) {
        this.onFloatViewClickListener = onFloatViewClickListener
    }

    interface OnFloatViewClickListener {
        fun onClick()
    }
}
