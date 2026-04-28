import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<CompleteOnboardingRequested>(_onCompleteOnboardingRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthState(isLoading: true, user: state.user)); // Drop error, start loading
    try {
      final user = await _authRepository.loginWithEmail(event.email, event.password);
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthState(isLoading: true, user: state.user));
    try {
      final user = await _authRepository.registerWithEmail(event.email, event.password);
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthState(isLoading: true, user: state.user));
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthState(isLoading: true, user: state.user));
    try {
      await _authRepository.logout();
      emit(const AuthState());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCompleteOnboardingRequested(CompleteOnboardingRequested event, Emitter<AuthState> emit) async {
    emit(AuthState(isLoading: true, user: state.user));
    try {
      final user = await _authRepository.completeOnboarding(
        nickname: event.nickname,
        school: event.school,
        primaryGoal: event.primaryGoal,
      );
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final user = await _authRepository.getCurrentUser();
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
