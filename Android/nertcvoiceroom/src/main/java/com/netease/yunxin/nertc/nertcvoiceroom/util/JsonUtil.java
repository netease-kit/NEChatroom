package com.netease.yunxin.nertc.nertcvoiceroom.util;

import android.text.TextUtils;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;


public class JsonUtil {


    private static final String TAG = "JsonUtil";

    /**
     * Map->String
     */
    public static String getJsonStringFromMap(final Map<String, Object> map) {
        String result = null;
        if (map != null && !map.isEmpty()) {
            try {
                JSONObject json = recursiveParseMap(map);
                result = json.toString();
            } catch (Exception e) {
                Log.e(TAG, "getJsonStringFromMap exception =" + e.getMessage());
            }
        }

        return result;
    }

    public static JSONObject parse(String json) {
        try {
            return new JSONObject(json);
        } catch (JSONException e) {
            Log.e(TAG, "parse exception =" + e.getMessage());
            return null;
        }
    }

    /**
     * String->Map
     */
    public static Map<String, Object> getMapFromJsonString(final String jsonStr) {
        if (TextUtils.isEmpty(jsonStr)) {
            return null;
        }

        Map<String, Object> result = null;
        try {
            JSONObject json = parse(jsonStr);
            result = recursiveParseJsonObject(json);
        } catch (JSONException e) {
            Log.e(TAG, "getMapFromJsonString exception =" + e.getMessage());
        } finally {
            if (result == null) {
                result = new HashMap<>(1);
                result.put("ext", jsonStr);
            }
        }

        return result;
    }


    private static JSONObject recursiveParseMap(Map map) throws JSONException {
        if (map == null) {
            return null;
        }

        JSONObject obj = new JSONObject();
        Iterator entries = map.entrySet().iterator();
        while (entries.hasNext()) {
            Map.Entry entry = (Map.Entry) entries.next();
            String key = String.valueOf(entry.getKey());
            Object value = entry.getValue();
            if (value instanceof List) {
                obj.put(key, recursiveParseList((List) value));
            } else if (value instanceof Map) {
                obj.put(key, recursiveParseMap((Map) value));
            } else if (value instanceof JSONObject) {
                obj.put(key, recursiveParseMap(recursiveParseJsonObject((JSONObject) value)));
            } else if (value instanceof JSONArray) {
                obj.put(key, recursiveParseList(recursiveParseJsonArray((JSONArray) value)));
            } else {
                obj.put(key, value);
            }
        }

        return obj;
    }


    private static JSONArray recursiveParseList(List list) throws JSONException {
        if (list == null) {
            return null;
        }
        JSONArray array = new JSONArray();
        for (Object o : list) {
            if (o instanceof List) {
                array.put(recursiveParseList((List) o));
            } else if (o instanceof Map) {
                array.put(recursiveParseMap((Map) o));
            } else {
                array.put(o);
            }
        }
        return array;
    }

    private static List recursiveParseJsonArray(JSONArray array) throws JSONException {
        if (array == null) {
            return null;
        }

        List list = new ArrayList(array.length());
        Object value;
        for (int m = 0; m < array.length(); m++) {
            value = array.get(m);
            if (value instanceof JSONArray) {
                list.add(recursiveParseJsonArray((JSONArray) value));
            } else if (value instanceof JSONObject) {
                list.add(recursiveParseJsonObject((JSONObject) value));
            } else {
                list.add(value);
            }
        }

        return list;
    }

    private static Map<String, Object> recursiveParseJsonObject(JSONObject json) throws JSONException {
        if (json == null) {
            return null;
        }

        Map<String, Object> map = new HashMap<>(json.length());
        String key;
        Object value;
        Iterator<String> i = json.keys();
        while (i.hasNext()) {
            key = i.next();
            value = json.get(key);
            if (value instanceof JSONArray) {
                map.put(key, recursiveParseJsonArray((JSONArray) value));
            } else if (value instanceof JSONObject) {
                map.put(key, recursiveParseJsonObject((JSONObject) value));
            } else {
                map.put(key, value);
            }
        }

        return map;
    }
}
