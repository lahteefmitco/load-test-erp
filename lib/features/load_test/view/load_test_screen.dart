import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/api_config.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/load_test_cubit.dart';
import '../cubit/load_test_state.dart';

class LoadTestScreen extends StatefulWidget {
  const LoadTestScreen({super.key});

  @override
  State<LoadTestScreen> createState() => _LoadTestScreenState();
}

class _LoadTestScreenState extends State<LoadTestScreen> {
  final _countController = TextEditingController(text: '10');

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _showSessionInfo() {
    final auth = context.read<AuthCubit>().state;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Session'),
          content: SingleChildScrollView(
            child: SelectableText(
              'Base URL\n${auth.baseUrl ?? ''}\n\nToken\n${auth.userToken ?? ''}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ERP Load Test'),
        actions: [
          IconButton(
            tooltip: 'Session info',
            onPressed: _showSessionInfo,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, auth) {
          return BlocBuilder<LoadTestCubit, LoadTestState>(
            builder: (context, load) {
              final canTest =
                  !load.running &&
                  (!load.endpoint.requiresAuth || auth.isAuthenticated);
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<LoadTestEndpoint>(
                    initialValue: load.endpoint,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'GET request',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final endpoint in LoadTestEndpoint.values)
                        DropdownMenuItem(
                          value: endpoint,
                          child: Text(endpoint.label),
                        ),
                    ],
                    onChanged: load.running
                        ? null
                        : (value) {
                            if (value != null) {
                              context.read<LoadTestCubit>().selectEndpoint(value);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _countController,
                    enabled: !load.running,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Parallel requests',
                      border: const OutlineInputBorder(),
                      errorText: load.validationMessage,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: canTest
                        ? () {
                            context.read<LoadTestCubit>().run(
                              parallelCountText: _countController.text,
                              userToken: auth.userToken,
                            );
                          }
                        : null,
                    icon: load.running
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(load.running ? 'Running' : 'Test'),
                  ),
                  if (load.hasResult) ...[
                    const SizedBox(height: 20),
                    _Summary(state: load),
                    const SizedBox(height: 16),
                    Text(
                      'Errors',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (load.errors.isEmpty)
                      const Text('No errors')
                    else
                      for (final error in load.errors)
                        Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: ListTile(
                            title: Text(error.message),
                            subtitle: Text(error.url),
                          ),
                        ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.state});

  final LoadTestState state;

  @override
  Widget build(BuildContext context) {
    final elapsed = state.elapsed;
    final elapsedLabel = elapsed == null
        ? '-'
        : '${elapsed.inMilliseconds} ms';

    return Row(
      children: [
        _Stat(label: 'Total', value: '${state.total ?? 0}'),
        _Stat(label: 'Success', value: '${state.successCount ?? 0}'),
        _Stat(label: 'Failed', value: '${state.failedCount ?? 0}'),
        _Stat(label: 'Elapsed', value: elapsedLabel),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(label),
        ],
      ),
    );
  }
}
