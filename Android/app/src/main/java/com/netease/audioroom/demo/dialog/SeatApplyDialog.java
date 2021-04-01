package com.netease.audioroom.demo.dialog;

import android.content.DialogInterface;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.SeatApplyAdapter;
import com.netease.audioroom.demo.util.ScreenUtil;
import com.netease.audioroom.demo.widget.VerticalItemDecoration;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

public class SeatApplyDialog extends BaseDialogFragment {

    RecyclerView requesterRecyclerView;

    SeatApplyAdapter adapter;

    View view;

    TextView title;

    TextView tvDismiss;

    private final List<VoiceRoomSeat> seats = new ArrayList<>();

    public interface IRequestAction {

        void refuse(VoiceRoomSeat seat);

        void agree(VoiceRoomSeat seat);

        void dismiss();

    }

    IRequestAction requestAction;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(DialogFragment.STYLE_NO_TITLE, R.style.request_dialog_fragment);
    }


    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        Bundle bundle = getArguments();
        if (bundle != null) {
            ArrayList<VoiceRoomSeat> seats = getArguments().getParcelableArrayList(TAG);
            if (seats != null) {
                this.seats.addAll(seats);
            }
        } else {
            dismiss();
        }
        view = inflater.inflate(R.layout.apply_list_dialog_layout, container, false);
        // 设置宽度为屏宽、靠近屏幕底部。
        final Window window = getDialog().getWindow();
        window.setBackgroundDrawableResource(R.color.color_00000000);
        WindowManager.LayoutParams wlp = window.getAttributes();
        wlp.gravity = Gravity.TOP;
        wlp.width = WindowManager.LayoutParams.MATCH_PARENT;
        wlp.height = WindowManager.LayoutParams.WRAP_CONTENT;
        window.setAttributes(wlp);
        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        initView();
        initListener();

    }

    private void initView() {
        requesterRecyclerView = view.findViewById(R.id.requesterRecyclerView);
        requesterRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
        int padding = ScreenUtil.dip2px(requesterRecyclerView.getContext(),16);
        requesterRecyclerView.addItemDecoration(
                new VerticalItemDecoration(getResources().getColor(R.color.color_33ffffff), 1, padding, padding));
        title = view.findViewById(R.id.title);
        tvDismiss = view.findViewById(R.id.dismiss);
        buildHeadView();
        refresh();
    }

    private void buildHeadView() {
        adapter = new SeatApplyAdapter(new ArrayList<>(), getActivity());
        requesterRecyclerView.setAdapter(adapter);
        requesterRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()) {

            @Override
            public void onMeasure(RecyclerView.Recycler recycler, RecyclerView.State state, int widthSpec,
                                  int heightSpec) {
                int count = state.getItemCount();
                if (count > 0) {
                    if (count > 4) {
                        count = 4;
                    }
                    int realHeight = 0;
                    int realWidth = 0;
                    for (int i = 0; i < count; i++) {
                        View view = recycler.getViewForPosition(0);
                        if (view != null) {
                            measureChild(view, widthSpec, heightSpec);
                            int measuredWidth = View.MeasureSpec.getSize(widthSpec);
                            int measuredHeight = view.getMeasuredHeight();
                            realWidth = realWidth > measuredWidth ? realWidth : measuredWidth;
                            realHeight += measuredHeight;
                        }
                        setMeasuredDimension(realWidth, realHeight);
                    }
                } else {
                    super.onMeasure(recycler, state, widthSpec, heightSpec);
                }
            }
        });
    }

    public void initListener() {
        adapter.setApplyAction(new SeatApplyAdapter.IApplyAction() {

            @Override
            public void refuse(VoiceRoomSeat seat) {
                requestAction.refuse(seat);
            }

            @Override
            public void agree(VoiceRoomSeat seat) {
                requestAction.agree(seat);
            }
        });
        tvDismiss.setOnClickListener((v) -> dismiss());
    }

    public void setRequestAction(IRequestAction requestAction) {
        this.requestAction = requestAction;
    }


    public void update(Collection<VoiceRoomSeat> seats) {
        this.seats.clear();
        this.seats.addAll(seats);
        if (isVisible()) {
            refresh();
        }
    }

    private void refresh() {
        title.setText(getString(R.string.apply_micro, seats.size()));
        adapter.setItems(seats);
    }

    @Override
    public void onDismiss(DialogInterface dialog) {
        super.onDismiss(dialog);
        requestAction.dismiss();

    }
}
