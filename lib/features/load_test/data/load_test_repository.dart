import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

class LoadTestCallResult {
  const LoadTestCallResult({
    required this.success,
    required this.url,
    this.errorMessage,
  });

  final bool success;
  final String url;
  final String? errorMessage;
}

class LoadTestRepository {
  LoadTestRepository(this._client);

  final DioClient _client;

  Future<LoadTestCallResult> call({
    required LoadTestEndpoint endpoint,
    String? userToken,
  }) async {
    final fallbackUrl = _fallbackUrl(endpoint);
    try {
      final headers = <String, String>{'accept': endpoint.accept};
      if (endpoint.requiresAuth && userToken != null && userToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $userToken';
      }
      final response = await _client.dio.get<dynamic>(
        endpoint.path,
        queryParameters: endpoint.query.isEmpty ? null : endpoint.query,
        options: Options(headers: headers),
      );
      return _interpret(
        data: response.data,
        url: response.requestOptions.uri.toString(),
        statusCode: response.statusCode ?? 0,
      );
    } on DioException catch (error) {
      final failure = apiExceptionFromDio(error, fallbackUrl: fallbackUrl);
      return LoadTestCallResult(
        success: false,
        url: failure.url,
        errorMessage: failure.message,
      );
    } catch (error) {
      return LoadTestCallResult(
        success: false,
        url: fallbackUrl,
        errorMessage: error.toString(),
      );
    }
  }

  String _fallbackUrl(LoadTestEndpoint endpoint) {
    final query = endpoint.query.entries
        .map((entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');
    if (query.isEmpty) {
      return ApiConfig.urlFor(endpoint.path, baseUrl: _client.dio.options.baseUrl);
    }
    return '${ApiConfig.urlFor(endpoint.path, baseUrl: _client.dio.options.baseUrl)}?$query';
  }

  LoadTestCallResult _interpret({
    required dynamic data,
    required String url,
    required int statusCode,
  }) {
    if (statusCode < 200 || statusCode >= 300) {
      return LoadTestCallResult(
        success: false,
        url: url,
        errorMessage: 'HTTP $statusCode',
      );
    }

    final decoded = _decode(data);
    if (decoded is List) {
      return LoadTestCallResult(success: true, url: url);
    }
    if (decoded is Map) {
      if (decoded.containsKey('status') && decoded['status'] != true) {
        return LoadTestCallResult(
          success: false,
          url: url,
          errorMessage: decoded['message']?.toString() ?? 'Response status is not true',
        );
      }
      return LoadTestCallResult(success: true, url: url);
    }

    return LoadTestCallResult(success: true, url: url);
  }

  dynamic _decode(dynamic data) {
    if (data is String && data.trim().isNotEmpty) {
      try {
        return jsonDecode(data);
      } on FormatException {
        return data;
      }
    }
    return data;
  }
}
