import 'package:equatable/equatable.dart';
import 'package:sakupintar/data/models/goal/goal_model.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoals extends GoalEvent {}

class GoalsUpdated extends GoalEvent {
  final List<GoalModel> goals;

  const GoalsUpdated(this.goals);

  @override
  List<Object?> get props => [goals];
}

class AddGoal extends GoalEvent {
  final GoalModel goal;

  const AddGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class SetActiveGoal extends GoalEvent {
  final String goalId;

  const SetActiveGoal(this.goalId);

  @override
  List<Object?> get props => [goalId];
}

class AddSavedAmount extends GoalEvent {
  final String goalId;
  final double amount;

  const AddSavedAmount(this.goalId, this.amount);

  @override
  List<Object?> get props => [goalId, amount];
}

class MarkGoalCompleted extends GoalEvent {
  final String goalId;

  const MarkGoalCompleted(this.goalId);

  @override
  List<Object?> get props => [goalId];
}

class GoalError extends GoalEvent {
  final String error;

  const GoalError(this.error);

  @override
  List<Object?> get props => [error];
}
