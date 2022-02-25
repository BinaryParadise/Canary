package com.example.flutter_canary

import okhttp3.HttpUrl
import okhttp3.Request
import okhttp3.Response
import okio.Buffer

class NetLogMessage {
    lateinit var method: String
    lateinit var requestURL: HttpUrl
    lateinit var requestHeaderFields: Map<String, Any>
    lateinit var responseHeaderFields: Map<String, Any>
    lateinit var requestBody: ByteArray;
    lateinit var responseBody: ByteArray;
    var statusCode: Int

    constructor(request: Request, response: Response) {
        method = request.method
        requestURL = request.url

        requestHeaderFields = request.headers.toMap()

        var buffer = Buffer()
        request.body?.writeTo(buffer)
        requestBody = buffer.readByteArray()

        responseHeaderFields = response.headers.toMap()
        statusCode = response.code

        var newbody = response.peekBody(Long.MAX_VALUE)
        responseBody = newbody.bytes()
    }
}