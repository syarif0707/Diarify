import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
Widget build(BuildContext context) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: onTap,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
    unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
    backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.insert_chart),  // Changed from bar_chart
        label: 'Reflections',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ],
  );
}
}