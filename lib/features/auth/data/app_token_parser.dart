import 'dart:convert';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_exception.dart';

/// App-auth returns `token` as a JSON string of `[{label, value, expiration}]`.
String extractAppJwt(dynamic tokenField, {required String baseUrl}) {
  if (tokenField is! String || tokenField.trim().isEmpty) {
    throw ApiException(
      message: 'App auth response did not include a token',
      url: ApiConfig.urlFor('/app-auth', baseUrl: baseUrl),
    );
  }

  final Object? decoded;
  try {
    decoded = jsonDecode(tokenField);
  } on FormatException {
    throw ApiException(
      message: 'App auth token could not be parsed',
      url: ApiConfig.urlFor('/app-auth', baseUrl: baseUrl),
    );
  }
  if (decoded is List && decoded.isNotEmpty) {
    final first = decoded.first;
    if (first is Map && first['value'] is String && (first['value'] as String).isNotEmpty) {
      return first['value'] as String;
    }
  }

  throw ApiException(
    message: 'App auth token could not be parsed',
    url: ApiConfig.urlFor('/app-auth', baseUrl: baseUrl),
  );
}
