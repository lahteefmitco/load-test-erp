import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/api_config.dart';
import '../data/load_test_repository.dart';
import 'load_test_state.dart';

class LoadTestCubit extends Cubit<LoadTestState> {
  LoadTestCubit(this._repository) : super(const LoadTestState());

  final LoadTestRepository _repository;

  void selectEndpoint(LoadTestEndpoint endpoint) {
    emit(state.copyWith(endpoint: endpoint, clearValidation: true));
  }

  Future<void> run({
    required String parallelCountText,
    String? userToken,
  }) async {
    if (state.endpoint.requiresAuth && (userToken == null || userToken.isEmpty)) {
      emit(
        state.copyWith(
          validationMessage: 'Sign in before testing this request',
        ),
      );
      return;
    }

    final count = int.tryParse(parallelCountText.trim());
    if (count == null || count < 1) {
      emit(
        state.copyWith(
          validationMessage: 'Enter a whole number of parallel requests (1 or more)',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        running: true,
        clearValidation: true,
        clearResult: true,
      ),
    );

    final stopwatch = Stopwatch()..start();
    final results = await Future.wait(
      List.generate(
        count,
        (_) => _repository.call(endpoint: state.endpoint, userToken: userToken),
      ),
    );
    stopwatch.stop();

    final errors = <RequestErrorLog>[
      for (final result in results)
        if (!result.success)
          RequestErrorLog(
            message: result.errorMessage ?? 'Request failed',
            url: result.url,
          ),
    ];

    emit(
      state.copyWith(
        running: false,
        total: results.length,
        successCount: results.length - errors.length,
        failedCount: errors.length,
        elapsed: stopwatch.elapsed,
        errors: errors,
      ),
    );
  }
}
