import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakupintar/data/repositories/goal_repository.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_event.dart';
import 'package:sakupintar/presentation/bloc/goal/goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository _repository;
  StreamSubscription? _goalsSubscription;

  GoalBloc({required GoalRepository repository})
      : _repository = repository,
        super(const GoalState()) {
    on<LoadGoals>(_onLoadGoals);
    on<GoalsUpdated>(_onGoalsUpdated);
    on<AddGoal>(_onAddGoal);
    on<SetActiveGoal>(_onSetActiveGoal);
    on<AddSavedAmount>(_onAddSavedAmount);
    on<MarkGoalCompleted>(_onMarkGoalCompleted);
    on<GoalError>(_onGoalError);
  }

  Future<void> _onLoadGoals(
    LoadGoals event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true).clearError());
    try {
      await _goalsSubscription?.cancel();
      _goalsSubscription = _repository.streamGoals().listen(
        (goals) => add(GoalsUpdated(goals)),
        onError: (error) {
          // Dispatch error event instead of returning empty list
          add(GoalError(error.toString()));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onGoalsUpdated(
    GoalsUpdated event,
    Emitter<GoalState> emit,
  ) {
    emit(state.copyWith(
      goals: event.goals,
      isLoading: false,
    ));
  }

  Future<void> _onAddGoal(
    AddGoal event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isSuccess: false).clearError());
    try {
      await _repository.addGoal(event.goal);
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSetActiveGoal(
    SetActiveGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await _repository.setActiveGoal(event.goalId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAddSavedAmount(
    AddSavedAmount event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await _repository.addSavedAmount(event.goalId, event.amount);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onMarkGoalCompleted(
    MarkGoalCompleted event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await _repository.markGoalCompleted(event.goalId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onGoalError(
    GoalError event,
    Emitter<GoalState> emit,
  ) {
    emit(state.copyWith(isLoading: false, error: event.error));
  }

  @override
  Future<void> close() {
    _goalsSubscription?.cancel();
    return super.close();
  }
}
