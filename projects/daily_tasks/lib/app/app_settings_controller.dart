import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsState {
  final bool isDarkMode;
  final bool isLoading;

  const AppSettingsState({
    this.isDarkMode = false,
    this.isLoading = true,
  });

  AppSettingsState copyWith({
    bool? isDarkMode,
    bool? isLoading,
  }) {
    return AppSettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AppSettingsController extends Notifier<AppSettingsState> {
  static const String _darkModeKey = 'tasknest_dark_mode';

  @override
  AppSettingsState build() {
    Future.microtask(loadSettings);

    return const AppSettingsState();
  }

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    state = state.copyWith(
      isDarkMode: prefs.getBool(_darkModeKey) ?? false,
      isLoading: false,
    );
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(isDarkMode: value);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }
}

final appSettingsControllerProvider =
    NotifierProvider<AppSettingsController, AppSettingsState>(
  AppSettingsController.new,
);