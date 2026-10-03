import '../../../core/config/api_config.dart';

class RequestErrorLog {
  const RequestErrorLog({required this.message, required this.url});

  final String message;
  final String url;
}

class LoadTestState {
  const LoadTestState({
    this.endpoint = LoadTestEndpoint.serviceComplaint,
    this.running = false,
    this.total,
    this.successCount,
    this.failedCount,
    this.elapsed,
    this.errors = const [],
    this.validationMessage,
  });

  final LoadTestEndpoint endpoint;
  final bool running;
  final int? total;
  final int? successCount;
  final int? failedCount;
  final Duration? elapsed;
  final List<RequestErrorLog> errors;
  final String? validationMessage;

  bool get hasResult => total != null;

  LoadTestState copyWith({
    LoadTestEndpoint? endpoint,
    bool? running,
    int? total,
    int? successCount,
    int? failedCount,
    Duration? elapsed,
    List<RequestErrorLog>? errors,
    String? validationMessage,
    bool clearValidation = false,
    bool clearResult = false,
  }) {
    return LoadTestState(
      endpoint: endpoint ?? this.endpoint,
      running: running ?? this.running,
      total: clearResult ? null : (total ?? this.total),
      successCount: clearResult ? null : (successCount ?? this.successCount),
      failedCount: clearResult ? null : (failedCount ?? this.failedCount),
      elapsed: clearResult ? null : (elapsed ?? this.elapsed),
      errors: clearResult ? const [] : (errors ?? this.errors),
      validationMessage: clearValidation
          ? null
          : (validationMessage ?? this.validationMessage),
    );
  }
}
