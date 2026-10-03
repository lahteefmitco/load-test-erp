enum AuthStatus {
  initial,
  appInProgress,
  appSuccess,
  userInProgress,
  userSuccess,
  failure,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.message = '',
    this.errorUrl,
    this.appToken,
    this.userToken,
    this.baseUrl,
    this.failureStep = AuthStatus.initial,
  });

  final AuthStatus status;
  final String message;
  final String? errorUrl;
  final String? appToken;
  final String? userToken;
  final String? baseUrl;
  final AuthStatus failureStep;

  bool get isAuthenticated => status == AuthStatus.userSuccess && userToken != null;

  bool get appAuthenticated => appToken != null && appToken!.isNotEmpty;

  bool get isBusy =>
      status == AuthStatus.appInProgress || status == AuthStatus.userInProgress;

  AuthState copyWith({
    AuthStatus? status,
    String? message,
    String? errorUrl,
    String? appToken,
    String? userToken,
    String? baseUrl,
    AuthStatus? failureStep,
    bool clearErrorUrl = false,
    bool clearAppToken = false,
    bool clearUserToken = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorUrl: clearErrorUrl ? null : (errorUrl ?? this.errorUrl),
      appToken: clearAppToken ? null : (appToken ?? this.appToken),
      userToken: clearUserToken ? null : (userToken ?? this.userToken),
      baseUrl: baseUrl ?? this.baseUrl,
      failureStep: failureStep ?? this.failureStep,
    );
  }
}
