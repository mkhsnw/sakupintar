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

abstract class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const addTransaction = '/transaction/add';
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
      final isAuthPage = loc == Routes.login || loc == Routes.register || loc == Routes.otp;

      if (user == null && !isAuthPage && loc != Routes.splash) {
        return Routes.login;
      }
      if (user != null && isAuthPage) return Routes.dashboard;
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
        builder: (_, __) => const _Placeholder('Tambah Transaksi'),
      ),
      GoRoute(
        path: Routes.analytics,
        builder: (_, __) => const _Placeholder('Analitik ARSA'),
      ),
      GoRoute(
        path: Routes.goals,
        builder: (_, __) => const _Placeholder('Target Keuangan'),
      ),
      GoRoute(
        path: Routes.addGoal,
        builder: (_, __) => const _Placeholder('Tambah Target'),
      ),
      GoRoute(
        path: Routes.education,
        builder: (_, __) => const _Placeholder('Edukasi'),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (_, __) => const _Placeholder('Profil'),
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
        if (!state.isLoading && state.user != null) {
          final u = state.user!;
          if (u.nickname == null || u.school == null || u.primaryGoal == null) {
            context.go(Routes.onboarding);
          }
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state.user != null) {
          final u = state.user!;
          if (u.nickname == null || u.school == null || u.primaryGoal == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator())); // wait for redirect
          }
        }
        return child;
      },
    );
  }
}
