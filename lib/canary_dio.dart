import 'package:dio/dio.dart';
import 'package:flutter_canary/canary_manager.dart';

import 'model/model_result.dart';

class CanaryDio {
  static final CanaryDio _instance = CanaryDio._();
  static CanaryDio instance() => _instance;
  Dio _dio = Dio();

  CanaryDio._() {
    _dio = Dio();
    _dio.options.contentType = 'application/json; charset=utf8';
    _dio.interceptors.add(_CanaryDioInterceptor());
    FlutterCanary.instance.user.addListener(() {
      _dio.options.headers['Canary-Access-Token'] =
          FlutterCanary.instance.user.value?.token;
    });
  }

  void configure(String baseURL) {
    _dio.options.baseUrl = baseURL;
    _dio.options.connectTimeout = 30000;
  }

  Future<Result> get(String path, {Map<String, dynamic>? arguments}) async {
    try {
      var response = await _dio.get<Map>(path, queryParameters: arguments);
      var res = Result.fromJson(response.data as Map<String, dynamic>);
      return res;
    } on DioError catch (e) {
      if (e.response.statusCode == 401) {
        FlutterCanary.instance.user.value = null;
      } else {
        print(e);
      }
      return Result(1000, e.message);
    }
  }

  Future<Result> post(String path, {Map<String, dynamic>? arguments}) async {
    try {
      var response = await _dio.post<Map>(path, data: arguments);
      var res = Result.fromJson(response.data as Map<String, dynamic>);
      return res;
    } on DioError catch (e) {
      if (e.response.statusCode == 401) {
        FlutterCanary.instance.user.value = null;
      } else {
        print(e);
      }
      return Result(1000, e.message);
    }
  }
}

class _CanaryDioInterceptor extends Interceptor {}
