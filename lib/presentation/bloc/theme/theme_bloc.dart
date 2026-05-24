import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

export 'theme_event.dart';
export 'theme_state.dart';

const String _themePrefKey = 'selected_theme';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences sharedPreferences;

  ThemeBloc({required this.sharedPreferences}) : super(ThemeState.initial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ChangeTheme>(_onChangeTheme);
  }

  void _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) {
    final savedThemeString = sharedPreferences.getString(_themePrefKey);
    ThemeType themeType = ThemeType.blue; // Default

    if (savedThemeString != null) {
      if (savedThemeString == ThemeType.pink.name) {
        themeType = ThemeType.pink;
      } else if (savedThemeString == ThemeType.blue.name) {
        themeType = ThemeType.blue;
      }
    }
    
    emit(state.copyWith(themeType: themeType));
  }

  void _onChangeTheme(ChangeTheme event, Emitter<ThemeState> emit) async {
    await sharedPreferences.setString(_themePrefKey, event.themeType.name);
    emit(state.copyWith(themeType: event.themeType));
  }
}
