import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const RegisterRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class CompleteOnboardingRequested extends AuthEvent {
  final String nickname;
  final String school;
  final String primaryGoal;

  const CompleteOnboardingRequested({
    required this.nickname,
    required this.school,
    required this.primaryGoal,
  });

  @override
  List<Object?> get props => [nickname, school, primaryGoal];
}

class UpdateProfilePhoto extends AuthEvent {
  final File file;

  const UpdateProfilePhoto({required this.file});

  @override
  List<Object?> get props => [file];
}

class UpdateProfileRequested extends AuthEvent {
  final String nickname;
  final String school;
  final String primaryGoal;

  const UpdateProfileRequested({
    required this.nickname,
    required this.school,
    required this.primaryGoal,
  });

  @override
  List<Object?> get props => [nickname, school, primaryGoal];
}
