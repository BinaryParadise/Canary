package com.example.flutter_canary

import android.os.Handler
import android.os.Looper
import com.google.gson.Gson
import okhttp3.Interceptor
import okhttp3.Response
import java.lang.System.currentTimeMillis
import java.net.URLEncoder
import java.util.*
import kotlin.collections.HashMap

class CanaryOkHttpInterceptor : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        var request = chain.request()
        var response = chain.proceed(request)
        request.headers.toMap()
        storeNetLog(NetLogMessage(request, response))
        return response
    }

    fun storeNetLog(message: NetLogMessage) {
        var map = mutableMapOf<String, Any>()

        var gson = Gson()
        map["method"] = message.method
        var sceneid = message.requestHeaderFields.get("scene_id") as? String
        if (sceneid == null) {
            map["url"] = message.requestURL.toString();
        } else {
            var scenename = message.requestHeaderFields.get("scene_name") as? String

            map["url"] =
                message.requestURL.toString() + "&scene_id=" + sceneid + "&scene_name=" + URLEncoder.encode(
                    scenename,
                    "utf8"
                )
        }
        map["requestfields"] = message.requestHeaderFields
        map["requestbody"] = gson.fromJson(String(message.requestBody), Map::class.java)
        map["responsefields"] = message.responseHeaderFields
        map["responsebody"] = gson.fromJson(String(message.responseBody), Map::class.java)
        map["identify"] = UUID.randomUUID().toString().replace("-", "").lowercase()
        map["timestamp"] = currentTimeMillis()
        map["statusCode"] = message.statusCode
        // TODO: Mock场景
        map["flag"] = 4
        map["type"] = 2

        FlutterCanaryPlugin.storeLog(map)
    }
}