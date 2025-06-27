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
    return BottomAppBar(
      color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.bar_chart),
            color: currentIndex == 1 ? Theme.of(context).primaryColor : Colors.grey[200],
            onPressed: () => onTap(1),
          ),
          IconButton(
            icon: Icon(Icons.home,
                color: currentIndex == 0
                    ? Theme.of(context).floatingActionButtonTheme.backgroundColor
                    : Colors.grey[200]),
            onPressed: () => onTap(0),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
            color: currentIndex == 2 ? Theme.of(context).primaryColor : Colors.grey[200],
            onPressed: () => onTap(2),
          ),
        ],
      ),
    );
  }
}
