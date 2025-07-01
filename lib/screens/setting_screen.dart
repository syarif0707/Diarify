import 'package:diarify/app_settings.dart';
import 'package:diarify/screens/home_screen.dart';
import 'package:diarify/screens/reflection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../utils/app_constants.dart';
import '../auth/change_password_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppSettings>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
            ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: appSettings.themeMode == ThemeMode.dark,
              onChanged: (isOn) {
              appSettings.setThemeMode(isOn ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            leading: const Icon(Icons.dark_mode, color: Colors.white),
            onTap: () {
              appSettings.setThemeMode(
              appSettings.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              );
            },
            ),
          const Divider(),
          ListTile(
            title: const Text('Font Size'),
            trailing: DropdownButton<double>(
              value: appSettings.fontSizeScale,
              onChanged: (double? newValue) {
                if (newValue != null) {
                  appSettings.setFontSizeScale(newValue);
                }
              },
              items: const [
                DropdownMenuItem(value: 0.8, child: Text('Small')),
                DropdownMenuItem(value: 1.0, child: Text('Medium')),
                DropdownMenuItem(value: 1.2, child: Text('Large')),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Font Type'),
            trailing: DropdownButton<String>(
              value: appSettings.fontFamily,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  appSettings.setFontFamily(newValue);
                }
              },
              items: const [
                DropdownMenuItem(value: 'Roboto', child: Text('Default (Roboto)')),
                DropdownMenuItem(value: 'serif', child: Text('Serif (Fallback)')),
                DropdownMenuItem(value: 'sans-serif', child: Text('Sans-Serif (Fallback)')),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              AppConstants.currentUserId = null;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ReflectionScreen()),
            );
          }
        },
      ),
    );
  }
}