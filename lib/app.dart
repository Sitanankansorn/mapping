import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'state/user_profile_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/app_shell.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/settings_screen.dart';

/// Root widget. Configures reactive UserProfileScope, dynamic Dark/Light theme,
/// and named application routes.
class MappingApp extends StatefulWidget {
  const MappingApp({super.key});

  @override
  State<MappingApp> createState() => _MappingAppState();
}

class _MappingAppState extends State<MappingApp> {
  final UserProfileNotifier _userNotifier = UserProfileNotifier();

  @override
  void dispose() {
    _userNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UserProfileScope(
      notifier: _userNotifier,
      child: ListenableBuilder(
        listenable: _userNotifier,
        builder: (context, _) {
          final isDark = _userNotifier.profile.isDarkMode;
          return MaterialApp(
            title: 'Thailand Mapping',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/login',
            routes: {
              '/login': (_) => const LoginScreen(),
              '/signup': (_) => const SignupScreen(),
              '/home': (_) => const AppShell(),
              '/forgot-password': (_) => const ForgotPasswordScreen(),
              '/edit-profile': (_) => const EditProfileScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
