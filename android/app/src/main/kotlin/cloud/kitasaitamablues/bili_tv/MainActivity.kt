package cloud.kitasaitamablues.bili_tv

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.inputmethod.InputMethodManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "cloud.kitasaitamablues.bili_tv/ime"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
    }
}
