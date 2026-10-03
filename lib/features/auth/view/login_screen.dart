import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/api_config.dart';
import '../../load_test/view/load_test_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _baseUrlController = TextEditingController(text: ApiConfig.baseUrl);
  final _appUserController = TextEditingController(text: ApiConfig.clientId);
  final _appPasswordController = TextEditingController(text: ApiConfig.secret);
  final _userNameController = TextEditingController(text: ApiConfig.userName);
  final _userPasswordController = TextEditingController(text: ApiConfig.password);

  String? _urlError;
  String? _appUserError;
  String? _appPasswordError;
  String? _userNameError;
  String? _userPasswordError;
  bool _showAppPassword = false;
  bool _showUserPassword = false;

  @override
  void dispose() {
    _baseUrlController.dispose();
    _appUserController.dispose();
    _appPasswordController.dispose();
    _userNameController.dispose();
    _userPasswordController.dispose();
    super.dispose();
  }

  void _appAuth() {
    final url = _baseUrlController.text.trim();
    final userName = _appUserController.text.trim();
    final password = _appPasswordController.text;
    setState(() {
      _urlError = url.startsWith('http://') || url.startsWith('https://')
          ? null
          : 'Enter a base URL starting with http:// or https://';
      _appUserError = userName.isEmpty ? 'Enter the app auth username' : null;
      _appPasswordError = password.isEmpty ? 'Enter the app auth password' : null;
    });
    if (_urlError != null || _appUserError != null || _appPasswordError != null) {
      return;
    }
    context.read<AuthCubit>().appAuth(
      baseUrl: url,
      userName: userName,
      password: password,
    );
  }

  void _userAuth() {
    final userName = _userNameController.text.trim();
    final password = _userPasswordController.text;
    setState(() {
      _userNameError = userName.isEmpty ? 'Enter the user auth username' : null;
      _userPasswordError = password.isEmpty ? 'Enter the user auth password' : null;
    });
    if (_userNameError != null || _userPasswordError != null) {
      return;
    }
    context.read<AuthCubit>().userAuth(userName: userName, password: password);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != AuthStatus.userSuccess && current.status == AuthStatus.userSuccess,
      listener: (context, state) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const LoadTestScreen()),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, auth) {
            final busy = auth.isBusy;
            final appError = auth.status == AuthStatus.failure &&
                auth.failureStep == AuthStatus.appInProgress;
            final userError = auth.status == AuthStatus.failure &&
                auth.failureStep == AuthStatus.userInProgress;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _baseUrlController,
                  enabled: !busy,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Base URL',
                    border: const OutlineInputBorder(),
                    errorText: _urlError,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _appUserController,
                  enabled: !busy,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'App auth username',
                    border: const OutlineInputBorder(),
                    errorText: _appUserError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _appPasswordController,
                  enabled: !busy,
                  obscureText: !_showAppPassword,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'App auth password',
                    border: const OutlineInputBorder(),
                    errorText: _appPasswordError,
                    suffixIcon: IconButton(
                      tooltip: _showAppPassword ? 'Hide password' : 'Show password',
                      onPressed: () => setState(() => _showAppPassword = !_showAppPassword),
                      icon: Icon(_showAppPassword ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: busy ? null : _appAuth,
                  child: auth.status == AuthStatus.appInProgress
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('App auth'),
                ),
                if (auth.appAuthenticated) ...[
                  const SizedBox(height: 8),
                  const Text('App authenticated'),
                ],
                if (appError) ...[
                  const SizedBox(height: 8),
                  Text(auth.message),
                  if (auth.errorUrl != null) Text(auth.errorUrl!),
                ],
                const SizedBox(height: 24),
                TextField(
                  controller: _userNameController,
                  enabled: !busy && auth.appAuthenticated,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'User auth username',
                    border: const OutlineInputBorder(),
                    errorText: _userNameError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _userPasswordController,
                  enabled: !busy && auth.appAuthenticated,
                  obscureText: !_showUserPassword,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'User auth password',
                    border: const OutlineInputBorder(),
                    errorText: _userPasswordError,
                    suffixIcon: IconButton(
                      tooltip: _showUserPassword ? 'Hide password' : 'Show password',
                      onPressed: () => setState(() => _showUserPassword = !_showUserPassword),
                      icon: Icon(_showUserPassword ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: busy || !auth.appAuthenticated ? null : _userAuth,
                  child: auth.status == AuthStatus.userInProgress
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('User auth'),
                ),
                if (userError) ...[
                  const SizedBox(height: 8),
                  Text(auth.message),
                  if (auth.errorUrl != null) Text(auth.errorUrl!),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
