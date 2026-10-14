package ai.socialapps.apputils

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.util.Log
import com.dprotect.DpSdk
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/** Owns all Android state and threading for the DpSDK capability. */
internal class AntiScrapingHandler(context: Context) : MethodChannel.MethodCallHandler {
    private val applicationContext = context.applicationContext
    private val mainHandler = Handler(Looper.getMainLooper())
    private val executor: ExecutorService =
        Executors.newSingleThreadExecutor { runnable ->
            Thread(
                {
                    Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND)
                    runnable.run()
                },
                "apputils-anti-scraping",
            ).apply { isDaemon = true }
        }
    private val initializationLock = Any()

    @Volatile
    private var initialized = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "antiScraping.initialize" -> runAsync(result) {
                persistCuid(call.argument<String>(CUID_ARGUMENT_KEY).orEmpty())
                ensureInitialized()
                null
            }

            "antiScraping.getTicket" -> runAsync(result) {
                ensureInitialized()
                val ticket = DpSdk.getTicket().orEmpty()
                Log.i("DpSdk", "getTicket -> $ticket")
                ticket
            }

            "antiScraping.reportDeviceStatus" -> {
                // The supplied Android SDK has no matching reporting API.
                result.success(false)
            }

            else -> result.notImplemented()
        }
    }

    fun close() {
        executor.shutdown()
    }

    private fun persistCuid(cuid: String) {
        val committed = applicationContext
            .getSharedPreferences(
                "${applicationContext.packageName}_preferences",
                Context.MODE_PRIVATE,
            ).edit()
            .putString(DP_CUID_KEY, cuid)
            .commit()
        if (!committed) {
            throw AntiScrapingException(
                code = "storage_failed",
                message = "Failed to persist DP_CUID.",
            )
        }
    }

    private fun ensureInitialized() {
        if (initialized) return

        synchronized(initializationLock) {
            if (initialized) return

            if (!DpSdk.isLibraryLoaded()) {
                Log.e("DpSdk", "Library is not loaded: ${DpSdk.libraryLoadError()}")
                throw AntiScrapingException(
                    code = "sdk_unavailable",
                    message = "DpSDK cannot be loaded on this Android device.",
                    details = DpSdk.libraryLoadError()?.toString(),
                )
            }

            try {
                DpSdk.init(applicationContext)
                initialized = true
            } catch (error: Throwable) {
                Log.e("DpSdk", "DpSDK initialization failed", error)
                throw AntiScrapingException(
                    code = "initialization_failed",
                    message = "DpSDK initialization failed.",
                    details = error.toString(),
                )
            }
        }
    }

    private fun runAsync(result: MethodChannel.Result, operation: () -> Any?) {
        executor.execute {
            try {
                val value = operation()
                mainHandler.post { result.success(value) }
            } catch (error: AntiScrapingException) {
                Log.e("DpSdk", "AntiScrapingException: ${error.code} ${error.message} ${error.details}")
                mainHandler.post {
                    result.error(error.code, error.message, error.details)
                }
            } catch (error: Throwable) {
                Log.e("DpSdk", "Unexpected DpSDK failure", error)
                mainHandler.post {
                    result.error(
                        "native_error",
                        "Unexpected DpSDK failure.",
                        error.toString(),
                    )
                }
            }
        }
    }

    private companion object {
        const val CUID_ARGUMENT_KEY = "cuid"
        const val DP_CUID_KEY = "DP_CUID"
    }
}

private class AntiScrapingException(
    val code: String,
    override val message: String,
    val details: String? = null,
) : RuntimeException(message)
