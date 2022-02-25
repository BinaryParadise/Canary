package com.example.flutter_canary;

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import okhttp3.internal.wait
import java.util.concurrent.CountDownLatch
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

/**
 * FlutterCanaryPlugin
 */
class FlutterCanaryPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    companion object {
        private lateinit var channel: MethodChannel

        fun storeLog(map: Map<String, Any>) {
            Handler(Looper.getMainLooper()).post(Runnable {
                run {
                    channel.invokeMethod("forwardLog", map)
                }
            })
        }

        suspend fun configValue(key: String) = suspendCoroutine<String?> {
            Handler(Looper.getMainLooper()).post(Runnable {
                run {
                    channel.invokeMethod("configValue", key, object : Result {
                        override fun success(result: Any?) {
                            it.resume(result as? String)
                        }

                        override fun error(
                            errorCode: String?,
                            errorMessage: String?,
                            errorDetails: Any?
                        ) {
                            it.resume(null)
                        }

                        override fun notImplemented() {
                            it.resume(null)
                        }
                    })
                }
            })
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "flutter_canary")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            call.method.equals("getPlatformVersion") -> {
                result.success("Android " + android.os.Build.VERSION.RELEASE);
            }
            call.method.equals("enableNetLog") -> {
                if (call.arguments.equals("NetLogMode.okHttp")) {
                    // 默认开启
                }
                result.success(true);
            }
            call.method.equals("enableMock") -> {
                result.success(true);
            }
            call.method.equals("navigator.pop") -> {
                result.success(true);
            }
            else -> {
                result.notImplemented();
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
