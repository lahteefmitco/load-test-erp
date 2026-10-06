import 'package:dio/dio.dart';

import '../config/api_config.dart';

class DioClient {
  DioClient({Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              sendTimeout: ApiConfig.sendTimeout,
              headers: const {
                'accept': 'application/json, text/plain, */*',
                'Content-Type': 'application/json',
              },
            ),
          );

  final Dio dio;

  void setBaseUrl(String url) {
    final trimmed = url.trim();
    dio.options.baseUrl = trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }
}
