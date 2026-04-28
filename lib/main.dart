// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sakupintar/core/utils/app_router.dart';
import 'package:sakupintar/data/repositories/auth_repository.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_event.dart';
import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const SakuPintarApp());
}

class SakuPintarApp extends StatelessWidget {
  const SakuPintarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(AuthRepository())..add(const CheckAuthStatus()),
        ),
      ],
      child: MaterialApp.router(
        title: 'SakuPintar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
