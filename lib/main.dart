import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/models/todo_store.dart';
import 'features/models/user_share/user_share_pre.dart';
import 'features/presentation/add_task_screen.dart';
import 'features/presentation/getting_start.dart';
import 'features/presentation/setting_screen.dart';
import 'features/presentation/todo_screen.dart';
import 'features/profile/presentation/edit_profile_screen.dart';
import 'features/profile/presentation/user_profile_screen.dart';
import 'features/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final user = await UserSharePre().getUser();
  final userProvider = UserProvider();
  if (user != null) {
    userProvider.setUser(user);
  }
  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => MyApp(
    //     userProvider: userProvider,
    //     startScreen: user != null ? '/todo' : '/',
    //   ),
    // ),
    MyApp(
      userProvider: userProvider,
      startScreen: user != null ? '/todo' : '/',
    ),
  );
}

class MyApp extends StatelessWidget {
  final String startScreen;
  final UserProvider userProvider;

  const MyApp({
    super.key,
    required this.startScreen,
    required this.userProvider,
  });

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoStore()),
        ChangeNotifierProvider.value(value: userProvider),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final isDarkMode = userProvider.user?.isDarkMode ?? false;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: startScreen,
            routes: {
              '/': (BuildContext context) => const GettingStart(),
              '/todo': (BuildContext context) => const TodoScreen(),
              '/login': (BuildContext context) => const LoginScreen(),
              '/register': (BuildContext context) => const RegisterScreen(),
              '/add_task': (BuildContext context) => const AddTaskScreen(),
              '/settings': (BuildContext context) => const SettingScreen(),
              '/profile': (BuildContext context) => const UserProfileScreen(),
              '/edit_profile': (BuildContext context) =>
                  const EditProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
