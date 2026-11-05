package cloud.kitasaitamablues.bili_tv

import android.content.Context
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
    }
}
