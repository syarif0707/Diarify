import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_constants.dart';
import 'utils/app_settings.dart'; // Import AppSettings

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  await NotificationService().init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final appSettings = AppSettings(); // Create an instance
  await appSettings.init(); // Load initial settings

  runApp(
    ChangeNotifierProvider( // Provide AppSettings to the widget tree
      create: (context) => appSettings,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for changes in AppSettings
    final appSettings = context.watch<AppSettings>();

    return MaterialApp(
      title: 'Diarify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent[700],
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[700],
            foregroundColor: Colors.white,
          ),
        ),
        // Apply font family and scale to the default text theme
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: appSettings.fontFamily,
              fontSizeFactor: appSettings.fontSizeScale,
            ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent[400],
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[400],
            foregroundColor: Colors.white,
          ),
        ),
        // Apply font family and scale to the dark text theme
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: appSettings.fontFamily,
              fontSizeFactor: appSettings.fontSizeScale,
            ),
      ),
      themeMode: appSettings.themeMode, // Use the theme mode from settings
      home: AppConstants.currentUserId != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}