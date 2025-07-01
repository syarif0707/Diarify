import 'package:diarify/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_constants.dart';

void main() async {
  // In main.dart, ensure this comes before runApp():
WidgetsFlutterBinding.ensureInitialized();
final appSettings = AppSettings();
await appSettings.init();  // Make sure this completes
  await DatabaseHelper().database;
  await NotificationService().init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await appSettings.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => appSettings,
      child: const DiarifyApp(),
    ),
  );
}

class DiarifyApp extends StatelessWidget {
  const DiarifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettings>();

    return MaterialApp(
      title: 'Diarify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
          accentColor:Colors.white,
          backgroundColor: const Color.fromARGB(255, 95, 170, 193)!,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 1, 56, 102),
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromARGB(255, 11, 107, 187),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 1, 56, 102),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[500]!,
        ),
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: appSettings.fontFamily,
              fontSizeFactor: appSettings.fontSizeScale,
              bodyColor: const Color.fromARGB(255, 50, 62, 69),
              displayColor: Colors.white,
            ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blueGrey,
          secondary: Colors.blueAccent,
          surface: Colors.blueGrey[900]!,
          background: Colors.blueGrey[900]!,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent[400],
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blueGrey[900],
          selectedItemColor: Colors.blueAccent[400],
          unselectedItemColor: Colors.blueGrey[400],
        ),
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: appSettings.fontFamily,
              fontSizeFactor: appSettings.fontSizeScale,
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      themeMode: appSettings.themeMode,
      home: AppConstants.currentUserId != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}