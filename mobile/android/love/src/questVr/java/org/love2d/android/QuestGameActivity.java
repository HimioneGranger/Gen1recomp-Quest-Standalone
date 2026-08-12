package org.love2d.android;

import android.os.Bundle;

/** Quest-only Android host for the optional OpenXR backend. */
public class QuestGameActivity extends GameActivity {
    private static native void nativeQuestXrSetActivity(QuestGameActivity activity);
    private static native void nativeQuestXrStartBootstrap();
    private static native void nativeQuestXrDestroy();

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
    protected void onHostDestroy() {
        nativeQuestXrDestroy();
    }
}
