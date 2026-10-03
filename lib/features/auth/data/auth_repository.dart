import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'app_token_parser.dart';

class AuthRepository {
  AuthRepository(this._client);

  final DioClient _client;

  String get baseUrl => _client.dio.options.baseUrl;

  void setBaseUrl(String url) => _client.setBaseUrl(url);

  Future<String> appAuth({
    required String userName,
    required String password,
  }) async {
    const path = '/app-auth';
    try {
      final response = await _client.dio.post<dynamic>(
        path,
        data: {
          'clientId': userName,
          'secret': password,
        },
        options: Options(headers: {'accept': 'text/plain'}),
      );
      final body = _asMap(response.data, path);
      if (body['status'] != true) {
        throw ApiException(
          message: body['message']?.toString() ?? 'App auth failed',
          url: response.requestOptions.uri.toString(),
        );
      }
      return extractAppJwt(body['token'], baseUrl: baseUrl);
    } on DioException catch (error) {
      throw apiExceptionFromDio(error, fallbackUrl: ApiConfig.urlFor(path, baseUrl: baseUrl));
    }
  }

  Future<String> userAuth({
    required String appToken,
    required String userName,
    required String password,
  }) async {
    const path = '/user-auth';
    try {
      final data = {
        'userName': userName,
        'password': password,
        'location': ApiConfig.location,
        'macId': ApiConfig.macId,
        'area': ApiConfig.area,
        'routId': ApiConfig.routId,
      };
      log('data: $data');
      final response = await _client.dio.post<dynamic>(
        path,
        data: {
          'userName': userName,
          'password': password,
          'location': ApiConfig.location,
          'macId': ApiConfig.macId,
          'area': ApiConfig.area,
          'routId': ApiConfig.routId,
        },
        options: Options(
          headers: {
            'accept': 'text/plain',
            'Authorization': 'Bearer $appToken',
          },
        ),
      );
      final body = _asMap(response.data, path);
      final token = body['token'];
      if (body['status'] != true || token is! String || token.isEmpty) {
        throw ApiException(
          message: body['message']?.toString() ?? 'User auth failed',
          url: response.requestOptions.uri.toString(),
        );
      }
      return token;
    } on DioException catch (error) {
      throw apiExceptionFromDio(error, fallbackUrl: ApiConfig.urlFor(path, baseUrl: baseUrl));
    }
  }

  Map<String, dynamic> _asMap(dynamic data, String path) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
    throw ApiException(
      message: 'Unexpected response body',
      url: ApiConfig.urlFor(path, baseUrl: baseUrl),
    );
  }
}
