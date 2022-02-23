package com.example.flutter_canary_example;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.example.flutter_canary.CanaryOkHttpInterceptor;

import java.io.IOException;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okio.BufferedSink;

public class ExampleTestPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "canary_example_channel");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("logger")) {
            result.success(true);
        } else if (call.method.equals("logger-request")) {
            doRequest("https://api.m.taobao.com/rest/api3.do?api=mtop.common.getTimestamp");
            result.success(true);
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    public void doRequest(String url) {
        // 1 获取OkHttpClient对象
        OkHttpClient client = new OkHttpClient
                .Builder()
                .addNetworkInterceptor(new CanaryOkHttpInterceptor())
                .build();
        // 2设置请求
        Request request = new Request.Builder()
                .post(RequestBody.create("{'a':10}", MediaType.get("application/json")))
                .url(url)
                .build();

        // 3封装call
        Call call = client.newCall(request);
        // 4异步调用,并设置回调函数
        call.enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                // ...
            }

            @Override
            public void onResponse(Call call, final Response response) throws IOException {
                if (response != null && response.isSuccessful()) {
                    System.out.println(response.peekBody(Long.MAX_VALUE).string());
                }
            }
        });
        //同步调用,返回Response,会抛出IO异常
        //Response response = call.execute();
    }
}
