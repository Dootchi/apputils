package ai.socialapps.apputils

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

/** Registers the independent native capability channels owned by AppUtils. */
class ApputilsPlugin : FlutterPlugin {
    private var antiScrapingChannel: MethodChannel? = null
    private var antiScrapingHandler: AntiScrapingHandler? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val handler = AntiScrapingHandler(binding.applicationContext)
        val channel = MethodChannel(binding.binaryMessenger, ANTI_SCRAPING_CHANNEL)
        channel.setMethodCallHandler(handler)

        antiScrapingHandler = handler
        antiScrapingChannel = channel
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        antiScrapingChannel?.setMethodCallHandler(null)
        antiScrapingChannel = null
        antiScrapingHandler?.close()
        antiScrapingHandler = null
    }

    private companion object {
        const val ANTI_SCRAPING_CHANNEL = "ai.socialapps.apputils/anti_scraping"
    }
}
