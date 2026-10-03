import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({required this.message, required this.url});

  final String message;
  final String url;

  @override
  String toString() => '$message $url';
}

ApiException apiExceptionFromDio(DioException error, {String? fallbackUrl}) {
  final url = error.requestOptions.uri.toString().isNotEmpty
      ? error.requestOptions.uri.toString()
      : (fallbackUrl ?? error.requestOptions.path);

  final status = error.response?.statusCode;
  final bodyMessage = _messageFromBody(error.response?.data);
  final detail = bodyMessage ?? error.message ?? error.type.name;
  final message = status == null ? detail : 'HTTP $status: $detail';

  return ApiException(message: message, url: url);
}

String? _messageFromBody(dynamic data) {
  if (data is Map && data['message'] != null) {
    return data['message'].toString();
  }
  if (data is String && data.trim().isNotEmpty) {
    return data;
  }
  return null;
}
