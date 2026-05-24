import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sakupintar/presentation/pages/auth/login_page.dart';
import 'package:sakupintar/presentation/pages/auth/register_page.dart';
import 'package:sakupintar/presentation/pages/auth/splash_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakupintar/presentation/pages/auth/onboarding_page.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_bloc.dart';
import 'package:sakupintar/presentation/bloc/auth/auth_state.dart';
import 'package:sakupintar/presentation/pages/dashboard/dashboard_page.dart';
import 'package:sakupintar/presentation/pages/transaction/add_transaction_page.dart';
import 'package:sakupintar/presentation/pages/transaction/transaction_list_page.dart';
import 'package:sakupintar/presentation/pages/goal/add_goal_page.dart';
import 'package:sakupintar/presentation/pages/profile/profile_page.dart';

abstract class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const addTransaction = '/transaction/add';
  static const transactionList = '/transaction/list';
  static const analytics = '/analytics';
  static const goals = '/goals';
  static const addGoal = '/goals/add';
  static const education = '/education';
  static const profile = '/profile';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loc = state.matchedLocation;
      final isAuthPage =
          loc == Routes.login || loc == Routes.register || loc == Routes.otp;
      final isSplash = loc == Routes.splash;

      if (user == null && !isAuthPage && !isSplash) {
        return Routes.login;
      }
      if (user != null && (isAuthPage || isSplash)) {
        return Routes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashPage()),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: Routes.register, builder: (_, __) => const RegisterPage()),
      GoRoute(
        path: Routes.otp,
        builder: (_, __) => const _Placeholder('Verifikasi OTP'),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: Routes.dashboard,
        builder: (_, __) => const _DashboardGuard(child: DashboardPage()),
      ),
      GoRoute(
        path: Routes.addTransaction,
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'expense';
          final goalId = state.uri.queryParameters['goalId'];
          return AddTransactionPage(type: type, goalId: goalId);
        },
      ),
      GoRoute(
        path: Routes.analytics,
        builder: (_, __) => const _Placeholder('Analitik ARSA'),
      ),
      GoRoute(
        path: Routes.goals,
        builder: (_, __) => const _Placeholder('Target Keuangan'),
      ),
      GoRoute(path: Routes.addGoal, builder: (_, __) => const AddGoalPage()),
      GoRoute(
        path: Routes.education,
        builder: (_, __) => const _Placeholder('Edukasi'),
      ),
      GoRoute(
        path: Routes.transactionList,
        builder: (context, state) {
          final monthKey = state.uri.queryParameters['monthKey'] ?? '';
          return TransactionListPage(monthKey: monthKey);
        },
      ),
      GoRoute(
        path: Routes.profile,
        builder: (_, __) => const ProfilePage(),
      ),
    ],
    errorBuilder: (_, state) =>
        Scaffold(body: Center(child: Text('404: ${state.error}'))),
  );
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(title)),
  );
}

class _DashboardGuard extends StatelessWidget {
  final Widget child;

  const _DashboardGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!state.isLoading) {
          if (state.user == null) {
            context.go(Routes.login);
          } else {
            final u = state.user!;
            if (u.nickname == null || u.school == null || u.primaryGoal == null) {
              context.go(Routes.onboarding);
            }
          }
        }
      },
      builder: (context, state) {
        if (state.isLoading ||
            state.user == null ||
            (state.user != null &&
                (state.user!.nickname == null ||
                    state.user!.school == null ||
                    state.user!.primaryGoal == null))) {
          // Skeleton loading replacing CircularProgressIndicator
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 12,
                                  color: Colors.grey[200],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 140,
                                  height: 20,
                                  color: Colors.grey[200],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
