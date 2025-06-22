import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart'; // Import LoginScreen
import '../utils/app_constants.dart'; // For currentUserId
import '../utils/app_settings.dart'; // For AppSettings
import '../auth/change_password_screen.dart'; // For ChangePasswordScreen

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch AppSettings to react to changes
    final appSettings = context.watch<AppSettings>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Toggle
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: appSettings.themeMode == ThemeMode.dark,
              onChanged: (isOn) {
                appSettings.setThemeMode(isOn ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            onTap: () {
              // Also allow tapping the row to toggle
              appSettings.setThemeMode(
                appSettings.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
          const Divider(),

          // Font Size Dropdown
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

          // Font Type Dropdown (Conceptual - requires font assets/setup for real change)
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
                // To use custom fonts, you'd add them to pubspec.yaml and map their family names here.
                // e.g., DropdownMenuItem(value: 'OpenSans', child: Text('Open Sans')),
              ],
            ),
          ),
          const Divider(),

          // Change Password Button
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

          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Clear current user ID
              AppConstants.currentUserId = null;
              // Navigate back to Login Screen and clear navigation stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false, // Pop all routes until none left
              );
            },
          ),
        ],
      ),
    );
  }
}