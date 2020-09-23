package com.netease.audioroom.demo.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;


import com.netease.audioroom.demo.R;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class FileBrowserAdapter extends BaseAdapter {

    private List<FileItem> fileList = new ArrayList<>();
    private LayoutInflater layoutInflater;

    public FileBrowserAdapter(Context context, List<FileItem> fileList) {
        if (fileList != null) {
            this.fileList.addAll(fileList);
        }
        layoutInflater = LayoutInflater.from(context);
    }

    @Override
    public int getCount() {
        return fileList.size();
    }

    @Override
    public Object getItem(int position) {
        return fileList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = layoutInflater.inflate(R.layout.file_browser_list_item, parent, false);
        }

        FileHolder fileHolder = (FileHolder) convertView.getTag();
        if (fileHolder == null) {
            fileHolder = new FileHolder(convertView);
            convertView.setTag(fileHolder);
        }

        FileItem fileItem = (FileItem) getItem(position);
        File f = new File(fileItem.path);
        if (fileItem.getName().equals("@1")) {
            fileHolder.tvName.setText("/返回根目录");
            fileHolder.ivIcon.setImageResource(R.drawable.directory);
        } else if (fileItem.getName().equals("@2")) {
            fileHolder.tvName.setText("..返回上一级目录");
            fileHolder.ivIcon.setImageResource(R.drawable.directory);
        } else {
            fileHolder.tvName.setText(fileItem.getName());
            if (f.isDirectory()) {
                fileHolder.ivIcon.setImageResource(R.drawable.directory);
            } else if (f.isFile()) {
                fileHolder.ivIcon.setImageResource(R.drawable.file);
            }
        }

        return convertView;
    }


    public static class FileItem {
        private final String name;
        private final String path;

        public FileItem(String name, String path) {
            this.name = name;
            this.path = path;
        }

        public String getName() {
            return name;
        }

        public String getPath() {
            return path;
        }

    }


    private static class FileHolder {

        private final ImageView ivIcon;
        private final TextView tvName;

        FileHolder(View itemView) {
            ivIcon = itemView.findViewById(R.id.file_image);
            tvName = itemView.findViewById(R.id.file_name);
        }

    }
}
