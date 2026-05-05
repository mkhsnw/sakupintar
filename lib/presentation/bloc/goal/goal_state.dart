import 'package:equatable/equatable.dart';
import 'package:sakupintar/data/models/goal/goal_model.dart';

class GoalState extends Equatable {
  final List<GoalModel> goals;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const GoalState({
    this.goals = const [],
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  GoalModel? get activeGoal {
    try {
      return goals.firstWhere((g) => g.isActive);
    } catch (_) {
      if (goals.isNotEmpty) return goals.first;
      return null;
    }
  }

  List<GoalModel> get inactiveGoals {
    final active = activeGoal;
    return goals.where((g) => g.id != active?.id).toList();
  }

  GoalState copyWith({
    List<GoalModel>? goals,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return GoalState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  GoalState clearError() {
    return GoalState(
      goals: goals,
      isLoading: isLoading,
      error: null,
      isSuccess: isSuccess,
    );
  }

  @override
  List<Object?> get props => [goals, isLoading, error, isSuccess];
}
