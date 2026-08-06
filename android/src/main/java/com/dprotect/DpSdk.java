package com.dprotect;

import android.content.Context;

/**
 * JNI bridge required by libdpsdk.so.
 *
 * Keep this class name and its native method signatures unchanged: the supplied
 * library exports statically named JNI symbols for com.dprotect.DpSdk.
 */
public final class DpSdk {
    private static final Throwable LIBRARY_LOAD_ERROR;

    static {
        Throwable loadError = null;
        try {
            System.loadLibrary("dpsdk");
        } catch (Throwable error) {
            loadError = error;
        }
        LIBRARY_LOAD_ERROR = loadError;
    }

    private DpSdk() {}

    public static boolean isLibraryLoaded() {
        return LIBRARY_LOAD_ERROR == null;
    }

    public static Throwable libraryLoadError() {
        return LIBRARY_LOAD_ERROR;
    }

    public static native String getTicket();

    public static native void init(Context context);
}
