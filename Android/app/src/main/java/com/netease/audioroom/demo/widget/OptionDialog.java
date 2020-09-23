package com.netease.audioroom.demo.widget;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;

import java.util.List;


public class OptionDialog {

    public static class Option implements Comparable<Option> {
        private String title;
        private int value;

        public Option(String title, int value) {
            this.title = title;
            this.value = value;
        }

        public String getTitle() {
            return title;
        }

        public int getValue() {
            return value;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) {
                return true;
            }
            if (o == null || getClass() != o.getClass()) {
                return false;
            }
            Option option = (Option) o;
            return value == option.value;
        }

        @Override
        public int hashCode() {
            return value % 31;
        }

        @Override
        public int compareTo(@NonNull Option o) {
            return Integer.compare(value, o.value);
        }
    }

    public interface OptionListener {
        void onOptionClicked(Option selected);
    }

    private static CharSequence[] toCharSequences(List<Option> options) {
        CharSequence[] charSequences = new CharSequence[options.size()];
        int i = 0;
        for (Option o : options) {
            charSequences[i] = o.title;
            i++;
        }

        return charSequences;
    }

    public static AlertDialog.Builder make(Context context, List<Option> options, Option selected, OptionListener listener) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        if (options == null || options.isEmpty()) {
            return builder;
        }

        int index = options.indexOf(selected);
        if (index == -1) {
            return builder;
        }

        builder.setSingleChoiceItems(toCharSequences(options), index, (dialog, which) -> {
            if (listener != null) {
                if (which >= 0 && which < options.size()) {
                    listener.onOptionClicked(options.get(which));
                }
            }

            dialog.dismiss();
        });
        return builder;
    }
}
