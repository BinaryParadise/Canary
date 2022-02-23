package com.example.flutter_canary;

import androidx.annotation.NonNull;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

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

    }
}

class NetLogMessage {
    String method;
    HttpUrl requestURL;
    Map<String, Object> requestHeaderFields;
    Map<String, Object> responseHeaderFields;
    byte[] requestBody;
    byte[] responseBody;

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
        try {
            ResponseBody body = response.peekBody(Long.MAX_VALUE);
            responseBody = body.bytes();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}