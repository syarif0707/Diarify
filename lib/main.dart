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
  primaryColor: Color(0xFFC8B6FF), // Pastel Lilac
  scaffoldBackgroundColor: Color(0xFFFFE5EC), // Powder Pink
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFFC8B6FF),
    foregroundColor: Color(0xFF4A4A4A),
    elevation: 4,
    titleTextStyle: TextStyle(
      color: Color(0xFF4A4A4A),
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFC8B6FF), 
    foregroundColor: Color(0xFF4A4A4A),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFC8B6FF),
      foregroundColor: Color(0xFF4A4A4A),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFC8B6FF),            // pastel lilac background
    selectedItemColor: Color(0xFF4A4A4A),          // dark grey for selected icons
    unselectedItemColor: Color(0xFF937DC2),        // medium pastel purple for unselected
    selectedIconTheme: IconThemeData(size: 40),    // bigger selected icon
    unselectedIconTheme: IconThemeData(size: 34),  // slightly smaller unselected icon
  ),
  textTheme: Theme.of(context).textTheme.apply(
    bodyColor: Color(0xFF4A4A4A),
    displayColor: Color(0xFF4A4A4A),
    fontFamily: appSettings.fontFamily,
    fontSizeFactor: appSettings.fontSizeScale,
  ),
),

darkTheme: ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF3C2A4D), // Deep Mauve
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF7D5BA6), // Deep pastel lilac
    foregroundColor: Color(0xFFE3E3E3),
    elevation: 4,
    titleTextStyle: TextStyle(
      color: Color(0xFFE3E3E3),
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFA8E6CF), // Pastel mint
    foregroundColor: Color(0xFF3C2A4D),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF7D5BA6),
      foregroundColor: Color(0xFFE3E3E3),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF7D5BA6),            // dark pastel lilac background
    selectedItemColor: Color(0xFFE3E3E3),          // light grey for selected icons
    unselectedItemColor: Color(0xFFA8A0C4),        // medium pastel purple for unselected
    selectedIconTheme: IconThemeData(size: 40),    // bigger selected icon
    unselectedIconTheme: IconThemeData(size: 34),  // slightly smaller unselected icon
  ),
  textTheme: Theme.of(context).textTheme.apply(
    bodyColor: Color(0xFFE3E3E3),
    displayColor: Color(0xFFE3E3E3),
    fontFamily: appSettings.fontFamily,
    fontSizeFactor: appSettings.fontSizeScale,
  ),
),

      themeMode: appSettings.themeMode, // Use the theme mode from settings
      home: AppConstants.currentUserId != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}