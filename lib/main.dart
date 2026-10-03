import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/dio_client.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/load_test/cubit/load_test_cubit.dart';
import 'features/load_test/data/load_test_repository.dart';
import 'features/auth/view/login_screen.dart';

void main() {
  final dioClient = DioClient();
  runApp(LoadTestApp(dioClient: dioClient));
}

class LoadTestApp extends StatelessWidget {
  const LoadTestApp({super.key, required this.dioClient});

  final DioClient dioClient;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(AuthRepository(dioClient)),
        ),
        BlocProvider(
          create: (_) => LoadTestCubit(LoadTestRepository(dioClient)),
        ),
      ],
      child: MaterialApp(
        title: 'ERP Load Test',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
