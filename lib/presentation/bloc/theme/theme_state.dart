import 'package:equatable/equatable.dart';

enum ThemeType {
  blue,
  pink,
}

class ThemeState extends Equatable {
  final ThemeType themeType;

  const ThemeState({
    required this.themeType,
  });

  factory ThemeState.initial() {
    return const ThemeState(
      themeType: ThemeType.blue, // Default theme
    );
  }

  ThemeState copyWith({
    ThemeType? themeType,
  }) {
    return ThemeState(
      themeType: themeType ?? this.themeType,
    );
  }

  @override
  List<Object?> get props => [themeType];
}
