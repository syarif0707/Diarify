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
    final theme = Theme.of(context);
    final navTheme = theme.bottomNavigationBarTheme;

    Color getColor(int index) {
      return currentIndex == index
          ? navTheme.selectedItemColor ?? theme.primaryColor
          : navTheme.unselectedItemColor ?? Colors.grey[200]!;
    }

    double getSize(int index) {
      return currentIndex == index
          ? navTheme.selectedIconTheme?.size ?? 30
          : navTheme.unselectedIconTheme?.size ?? 25;
    }

    return BottomAppBar(
      color: navTheme.backgroundColor ?? theme.primaryColor,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.bar_chart),
            color: getColor(1),
            iconSize: getSize(1),
            onPressed: () => onTap(1),
          ),
          IconButton(
            icon: Icon(Icons.home),
            color: getColor(0),
            iconSize: getSize(0),
            onPressed: () => onTap(0),
          ),
          IconButton(
            icon: Icon(Icons.add_circle),
            color: getColor(2),
            iconSize: getSize(2),
            onPressed: () => onTap(2),
          ),
        ],
      ),
    );
  }
}
