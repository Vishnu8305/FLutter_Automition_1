import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved settings (avatarPath, userName)
  final prefs = await SharedPreferences.getInstance();
  final avatarPath =
      prefs.getString('avatarPath') ?? 'assets/avatars/avatar1.png';
  final userName = prefs.getString('userName') ?? 'John Doe';

  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDarkMode),
      child: MyApp(
        initialAvatarPath: avatarPath,
        initialUserName: userName,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialAvatarPath;
  final String initialUserName;

  MyApp({required this.initialAvatarPath, required this.initialUserName});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IoT App',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: SplashScreen(
        initialAvatarPath: initialAvatarPath,
        initialUserName: initialUserName,
      ),
    );
  }
}
