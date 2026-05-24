// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sakupintar/core/utils/app_router.dart';
import 'package:sakupintar/data/repositories/auth_repository.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_event.dart';
import 'package:sakupintar/data/repositories/transaction_repository.dart';
import 'package:sakupintar/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:sakupintar/data/repositories/category_repository.dart';
import 'package:sakupintar/presentation/bloc/category/category_bloc.dart';
import 'package:sakupintar/presentation/bloc/category/category_event.dart';
import 'package:sakupintar/data/repositories/goal_repository.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_bloc.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_event.dart';
import 'package:sakupintar/data/repositories/budget_repository.dart';
import 'package:sakupintar/presentation/bloc/budget/budget_bloc.dart';
import 'package:sakupintar/data/repositories/education_repository.dart';
import 'package:sakupintar/presentation/bloc/education/education_bloc.dart';
import 'package:sakupintar/presentation/bloc/theme/theme_bloc.dart';
import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);
  
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(SakuPintarApp(sharedPreferences: sharedPreferences));
}

class SakuPintarApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const SakuPintarApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc(sharedPreferences: sharedPreferences)..add(LoadTheme()),
        ),
        BlocProvider(
          create: (context) =>
              AuthBloc(AuthRepository())..add(const CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => TransactionBloc(
            repository: TransactionRepository(),
            goalRepository: GoalRepository(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              CategoryBloc(repository: CategoryRepository())
                ..add(LoadCategories()),
        ),
        BlocProvider(
          create: (context) =>
              GoalBloc(repository: GoalRepository())..add(LoadGoals()),
        ),
        BlocProvider(
          create: (context) => BudgetBloc(repository: BudgetRepository()),
        ),
        BlocProvider(
          create: (context) =>
              EducationBloc(repository: EducationRepository())..add(LoadEducation()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          // Set global theme variables dynamically based on state
          AppColors.setTheme(themeState.themeType == ThemeType.pink);

          return MaterialApp.router(
            key: ValueKey('theme_${themeState.themeType.name}'),
            title: 'SakuPintar',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
