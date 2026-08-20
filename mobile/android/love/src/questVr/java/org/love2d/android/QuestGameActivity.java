package org.love2d.android;

import android.os.Bundle;
import android.util.Log;

/** Quest-only Android host for the optional OpenXR backend. */
public class QuestGameActivity extends GameActivity {
    private static final String TAG = "QuestGameActivity";
    private static native void nativeQuestXrSetActivity(QuestGameActivity activity);
    private static native void nativeQuestXrStartBootstrap();
    private static native void nativeQuestXrDestroy();
    private static native void nativeQuestXrMarkSafReturn();
    private boolean pickerReturnPending;

    @Override
    protected String[] getHostLibraries() {
        return new String[] { "questxr" };
    }

    @Override
    protected void onHostCreateAfterSDL(Bundle savedInstanceState) {
        nativeQuestXrSetActivity(this);
        nativeQuestXrStartBootstrap();
    }

    @Override
    protected void onHostFilePickerReturned() {
        // Android owns return focus. The OpenXR bridge clears this only after
        // it observes a fresh valid tracked pose.
        pickerReturnPending = true;
        nativeQuestXrMarkSafReturn();
        Log.i(TAG, "Quest SAF return waiting for tracked pose");
    }

    /** Called by native code after a valid tracked pose returns. */
    public void onQuestXrSafPoseReady() {
        runOnUiThread(new Runnable() {
            @Override public void run() {
                if (pickerReturnPending && hasWindowFocus()) {
                    pickerReturnPending = false;
                    Log.i(TAG, "Quest SAF tracked pose ready");
                }
            }
        });
    }

    @Override
    protected void onHostDestroy() {
        nativeQuestXrDestroy();
    }
}
