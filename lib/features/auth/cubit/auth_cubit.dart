import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> appAuth({
    required String baseUrl,
    required String userName,
    required String password,
  }) async {
    _repository.setBaseUrl(baseUrl);
    emit(
      state.copyWith(
        status: AuthStatus.appInProgress,
        message: 'Authenticating app',
        baseUrl: _repository.baseUrl,
        clearErrorUrl: true,
        clearAppToken: true,
        clearUserToken: true,
      ),
    );

    try {
      final appToken = await _repository.appAuth(
        userName: userName,
        password: password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.appSuccess,
          message: 'App authenticated',
          appToken: appToken,
          baseUrl: _repository.baseUrl,
          clearErrorUrl: true,
          clearUserToken: true,
        ),
      );
    } on ApiException catch (error) {
      _emitFailure(AuthStatus.appInProgress, error.message, error.url);
    } catch (error) {
      _emitFailure(AuthStatus.appInProgress, error.toString(), null);
    }
  }

  Future<void> userAuth({
    required String userName,
    required String password,
  }) async {
    final appToken = state.appToken;
    if (appToken == null || appToken.isEmpty) {
      _emitFailure(AuthStatus.userInProgress, 'App auth is required first', state.baseUrl);
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.userInProgress,
        message: 'Authenticating user',
        clearErrorUrl: true,
        clearUserToken: true,
      ),
    );

    try {
      final userToken = await _repository.userAuth(
        appToken: appToken,
        userName: userName,
        password: password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.userSuccess,
          message: 'User authenticated',
          userToken: userToken,
          clearErrorUrl: true,
        ),
      );
    } on ApiException catch (error) {
      _emitFailure(AuthStatus.userInProgress, error.message, error.url);
    } catch (error) {
      _emitFailure(AuthStatus.userInProgress, error.toString(), null);
    }
  }

  void _emitFailure(AuthStatus step, String message, String? url) {
    emit(
      state.copyWith(
        status: AuthStatus.failure,
        failureStep: step,
        message: message,
        errorUrl: url,
        clearErrorUrl: url == null,
        clearUserToken: true,
        clearAppToken: step == AuthStatus.appInProgress,
      ),
    );
  }
}
