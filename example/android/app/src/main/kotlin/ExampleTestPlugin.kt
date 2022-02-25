package com.example.flutter_canary_example

import android.util.Log
import com.example.flutter_canary.CanaryOkHttpInterceptor
import com.example.flutter_canary.FlutterCanaryPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
import kotlin.coroutines.CoroutineContext

const val LogTag = "canary_demo"

class ExampleTestPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, CoroutineScope {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "canary_example_channel")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method.equals("logger")) {
            launch {
                var value = FlutterCanaryPlugin.configValue("TestParam1")
                Log.i(LogTag, value ?: "null")
            }
            result.success(true)
        } else if (call.method.equals("logger-request")) {
            doRequest("https://api.m.taobao.com/rest/api3.do?api=mtop.common.getTimestamp")
            result.success(true)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    fun doRequest(url: String) {
        // 1 获取OkHttpClient对象
        var client = OkHttpClient
            .Builder()
            .addNetworkInterceptor(CanaryOkHttpInterceptor())
            .build()

        // 2设置请求
        var request = Request.Builder()
            .url(url)
            .post("{'a':10}".toRequestBody("application/json".toMediaType()))
            .build()

        // 3封装call
        var call = client.newCall(request)
        // 4异步调用,并设置回调函数
        call.enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                Log.d(LogTag, "onFailure" + e.message)
            }

            @Throws(IOException::class)
            override fun onResponse(call: Call, response: Response) {
                Log.d(LogTag, "onResponse" + response)
            }

        })
        //同步调用,返回Response,会抛出IO异常
        //Response response = call.execute();
    }

    private var job = Job()
    override val coroutineContext: CoroutineContext
        get() = Dispatchers.Main + job
}
