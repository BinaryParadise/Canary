package com.example.flutter_canary;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.google.gson.Gson;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import okhttp3.HttpUrl;
import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;
import okio.Buffer;

public class CanaryOkHttpInterceptor implements Interceptor {
    @NonNull
    @Override
    public Response intercept(@NonNull Chain chain) throws IOException {
        //TODO: 转发到金丝雀
        Request request = chain.request();
        Response response = chain.proceed(request);
        storeNetLog(new NetLogMessage(request, response));
        return response;
    }

    void storeNetLog(NetLogMessage message) {
        Map map = new HashMap();
        Gson gson = new Gson();
        map.put("method", message.getMethod());
        String sceneid = (String) message.getResponseHeaderFields().get("scene_id");
        if (sceneid == null) {
            map.put("url", message.getRequestURL().toString());
        } else {
            String scenename = (String) message.getResponseHeaderFields().get("scene_name");
            try {
                map.put("url", message.getRequestURL().toString() + "&scene_id=" + sceneid + "&scene_name=" + URLEncoder.encode(scenename, "utf8"));
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
        }
        map.put("requestfields", message.getRequestHeaderFields());
        map.put("requestbody", gson.fromJson(new String(message.getRequestBody()), HashMap.class));
        map.put("responsefields", message.getResponseHeaderFields());
        map.put("responsebody", gson.fromJson(new String(message.getResponseBody()), HashMap.class));
        map.put("identify", UUID.randomUUID().toString().replace("-", "").toLowerCase());
        map.put("timestamp", System.currentTimeMillis());
        map.put("statusCode", message.getStatusCode());
        // TODO: Mock场景
        map.put("flag", 4);
        map.put("type", 2);
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                FlutterCanaryPlugin.channel.invokeMethod("forwardLog", map);
            }
        });
    }
}

class NetLogMessage {
    private String method;
    private HttpUrl requestURL;
    private Map<String, Object> requestHeaderFields;
    private Map<String, Object> responseHeaderFields;
    private byte[] requestBody;
    private byte[] responseBody;

    public int getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(int statusCode) {
        this.statusCode = statusCode;
    }

    private int statusCode;

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public HttpUrl getRequestURL() {
        return requestURL;
    }

    public void setRequestURL(HttpUrl requestURL) {
        this.requestURL = requestURL;
    }

    public Map<String, Object> getRequestHeaderFields() {
        return requestHeaderFields;
    }

    public void setRequestHeaderFields(Map<String, Object> requestHeaderFields) {
        this.requestHeaderFields = requestHeaderFields;
    }

    public Map<String, Object> getResponseHeaderFields() {
        return responseHeaderFields;
    }

    public void setResponseHeaderFields(Map<String, Object> responseHeaderFields) {
        this.responseHeaderFields = responseHeaderFields;
    }

    public byte[] getRequestBody() {
        return requestBody;
    }

    public void setRequestBody(byte[] requestBody) {
        this.requestBody = requestBody;
    }

    public byte[] getResponseBody() {
        return responseBody;
    }

    public void setResponseBody(byte[] responseBody) {
        this.responseBody = responseBody;
    }

    public NetLogMessage(Request request, Response response) {
        method = request.method();
        requestURL = request.url();

        requestHeaderFields = new HashMap<>();
        request.headers().forEach(a -> requestHeaderFields.put(a.component1(), a.component2()));
        try {
            Buffer buffer = new Buffer();
            request.body().writeTo(buffer);
            requestBody = buffer.readByteArray();
        } catch (IOException e) {
            e.printStackTrace();
        }

        responseHeaderFields = new HashMap<>();
        response.headers().forEach(a -> responseHeaderFields.put(a.component1(), a.component2()));
        statusCode = response.code();
        try {
            ResponseBody body = response.peekBody(Long.MAX_VALUE);
            responseBody = body.bytes();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}