package cloud.kitasaitamablues.bili_tv

import android.content.Context
import android.media.MediaCodecInfo
import android.media.MediaCodecList
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Display
import android.view.inputmethod.InputMethodManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val IME_CHANNEL = "cloud.kitasaitamablues.bili_tv/ime"
    private val DISPLAY_CHANNEL = "cloud.kitasaitamablues.bili_tv/display"
    private val CODEC_CHANNEL = "cloud.kitasaitamablues.bili_tv/codec"

    // 缓存硬件解码器能力，避免每次请求重复扫描系统编解码器列表
    private val hardwareVideoCapabilities = mutableMapOf<String, MutableList<MediaCodecInfo.VideoCapabilities>>()
    private var isCapabilitiesInitialized = false

    private fun initHardwareCodecCapabilities() {
        if (isCapabilitiesInitialized) return
        try {
            val codecList = MediaCodecList(MediaCodecList.REGULAR_CODECS)
            for (info in codecList.codecInfos) {
                if (info.isEncoder) continue
                val isHardware = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    info.isHardwareAccelerated
                } else {
                    val name = info.name.lowercase()
                    !name.startsWith("omx.google.") &&
                    !name.startsWith("c2.android.") &&
                    !name.contains("sw")
                }
                if (!isHardware) continue

                for (type in info.supportedTypes) {
                    if (type.startsWith("video/", ignoreCase = true)) {
                        try {
                            val caps = info.getCapabilitiesForType(type)
                            val vCaps = caps.videoCapabilities
                            if (vCaps != null) {
                                val list = hardwareVideoCapabilities.getOrPut(type.lowercase()) { mutableListOf() }
                                list.add(vCaps)
                            }
                        } catch (_: Exception) {}
                    }
                }
            }
            isCapabilitiesInitialized = true
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun isStreamSupported(mime: String, width: Int, height: Int, frameRate: Double): Boolean {
        initHardwareCodecCapabilities()
        val capsList = hardwareVideoCapabilities[mime.lowercase()] ?: return false
        if (capsList.isEmpty()) return false

        for (vCaps in capsList) {
            try {
                if (frameRate > 0.0) {
                    if (vCaps.areSizeAndRateSupported(width, height, frameRate)) {
                        return true
                    }
                } else {
                    if (vCaps.isSizeSupported(width, height)) {
                        return true
                    }
                }
            } catch (_: Exception) {}
        }
        return false
    }

    private fun getDecoderCapabilities(): Map<String, Any> {
        initHardwareCodecCapabilities()
        var maxOverallWidth = 0
        var maxOverallHeight = 0
        var maxOverallFps = 0.0
        var supports4k = false
        var supports8k = false
        var supports4k60 = false
        var supports4k120 = false

        for ((_, list) in hardwareVideoCapabilities) {
            for (vCaps in list) {
                try {
                    val w = vCaps.supportedWidths.upper
                    val h = vCaps.supportedHeights.upper
                    val fps = vCaps.supportedFrameRates.upper.toDouble()

                    if (w > maxOverallWidth) maxOverallWidth = w
                    if (h > maxOverallHeight) maxOverallHeight = h
                    if (fps > maxOverallFps) maxOverallFps = fps

                    if (vCaps.isSizeSupported(3840, 2160)) {
                        supports4k = true
                        if (vCaps.areSizeAndRateSupported(3840, 2160, 60.0)) {
                            supports4k60 = true
                        }
                        if (vCaps.areSizeAndRateSupported(3840, 2160, 120.0)) {
                            supports4k120 = true
                        }
                    }

                    if (vCaps.isSizeSupported(7680, 4320)) {
                        supports8k = true
                    }
                } catch (_: Exception) {}
            }
        }

        return mapOf(
            "maxOverallWidth" to maxOverallWidth,
            "maxOverallHeight" to maxOverallHeight,
            "maxOverallFps" to maxOverallFps,
            "supports4k" to supports4k,
            "supports8k" to supports8k,
            "supports4k60" to supports4k60,
            "supports4k120" to supports4k120
        )
    }

    private fun checkTracksSupport(tracks: List<Map<String, Any>>): List<Boolean> {
        initHardwareCodecCapabilities()
        val results = mutableListOf<Boolean>()
        for (track in tracks) {
            val mime = track["mime"] as? String ?: ""
            val width = (track["width"] as? Number)?.toInt() ?: 0
            val height = (track["height"] as? Number)?.toInt() ?: 0
            val fps = (track["frameRate"] as? Number)?.toDouble() ?: 0.0

            if (width <= 0 || height <= 0) {
                results.add(true)
                continue
            }

            val supported = isStreamSupported(mime, width, height, fps)
            results.add(supported)
        }
        return results
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. 输入法软键盘通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IME_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "showIme" -> {
                    Handler(Looper.getMainLooper()).postDelayed({
                        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
                        val view = currentFocus ?: window.decorView
                        imm?.showSoftInput(view, InputMethodManager.SHOW_FORCED)
                    }, 100)
                    result.success(true)
                }
                "hideIme" -> {
                    val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
                    val view = currentFocus ?: window.decorView
                    imm?.hideSoftInputFromWindow(view.windowToken, 0)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 2. 显示屏幕与硬件 HDR / 杜比视界能力探测通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DISPLAY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getHdrCapabilities" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                display ?: windowManager.defaultDisplay
                            } else {
                                @Suppress("DEPRECATION")
                                windowManager.defaultDisplay
                            }

                            val hdrCaps = display?.hdrCapabilities
                            val supportedTypes = hdrCaps?.supportedHdrTypes ?: intArrayOf()
                            var hasHdr10 = false
                            var hasDolbyVision = false
                            var hasHlg = false

                            for (type in supportedTypes) {
                                when (type) {
                                    Display.HdrCapabilities.HDR_TYPE_HDR10 -> hasHdr10 = true
                                    Display.HdrCapabilities.HDR_TYPE_DOLBY_VISION -> hasDolbyVision = true
                                    Display.HdrCapabilities.HDR_TYPE_HLG -> hasHlg = true
                                    4 -> { // HDR_TYPE_HDR10_PLUS (API 29+)
                                        hasHdr10 = true
                                    }
                                }
                            }

                            val maxLum = hdrCaps?.desiredMaxLuminance?.toDouble() ?: 0.0

                            result.success(
                                mapOf(
                                    "isHdrSupported" to supportedTypes.isNotEmpty(),
                                    "hasHdr10" to hasHdr10,
                                    "hasDolbyVision" to hasDolbyVision,
                                    "hasHlg" to hasHlg,
                                    "maxLuminance" to maxLum
                                )
                            )
                        } else {
                            result.success(
                                mapOf(
                                    "isHdrSupported" to false,
                                    "hasHdr10" to false,
                                    "hasDolbyVision" to false,
                                    "hasHlg" to false,
                                    "maxLuminance" to 0.0
                                )
                            )
                        }
                    } catch (e: Exception) {
                        result.success(
                            mapOf(
                                "isHdrSupported" to false,
                                "hasHdr10" to false,
                                "hasDolbyVision" to false,
                                "hasHlg" to false,
                                "maxLuminance" to 0.0
                            )
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 3. 硬件视频编解码能力动态探测通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CODEC_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDecoderCapabilities" -> {
                    try {
                        result.success(getDecoderCapabilities())
                    } catch (e: Exception) {
                        result.success(
                            mapOf(
                                "maxOverallWidth" to 3840,
                                "maxOverallHeight" to 2160,
                                "maxOverallFps" to 60.0,
                                "supports4k" to true,
                                "supports8k" to false,
                                "supports4k60" to true,
                                "supports4k120" to false
                            )
                        )
                    }
                }
                "checkTracksSupport" -> {
                    try {
                        @Suppress("UNCHECKED_CAST")
                        val tracks = call.argument<List<Map<String, Any>>>("tracks") ?: emptyList()
                        result.success(checkTracksSupport(tracks))
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
