package org.koreader.launcher;

import android.app.Activity;
import android.content.Context;
import android.content.ClipData;
import android.content.ClipDescription;
import android.content.ClipboardManager;
import android.util.Log;

import java.util.concurrent.CountDownLatch;

public class Clipboard {

    private static String TAG;
    private static Context context;
    private static ClipboardManager clipboard;

    public Clipboard(Context context, String logger_name) {
        this.context = context;
        this.TAG = logger_name;
        this.clipboard = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
    }

    public String getClipboardText() {
        final Box<String> result = new Box<String>();
        final CountDownLatch cd = new CountDownLatch(1);
        ((Activity)context).runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    if (clipboardHasText()) {
                        ClipData.Item item = clipboard.getPrimaryClip().getItemAt(0);
                        result.value = item.getText().toString();
                    }
                } catch (Exception e) {
                    Log.v(TAG, e.toString());
                    result.value = "";
                }
                cd.countDown();
            }
        });
        try {
            cd.await();
        } catch (InterruptedException ex) {
            return "";
        }

        if (result.value == null) {
            return "";
        }
        return result.value;
    }

    public void setClipboardText(final String text) {
        ((Activity)context).runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    ClipData clip = ClipData.newPlainText("KOReader_clipboard", text);
                    clipboard.setPrimaryClip(clip);
                } catch (Exception e) {
                    Log.v(TAG, e.toString());
                }
            }
        });
    }

    public int hasClipboardText() {
        return (clipboardHasText()) ? 1 : 0;
    }


    private boolean clipboardHasText() {
        return clipboard.hasPrimaryClip() && clipboard.getPrimaryClipDescription().hasMimeType(ClipDescription.MIMETYPE_TEXT_PLAIN);
    }

    private class Box<T> {
        public T value;
    }
}
