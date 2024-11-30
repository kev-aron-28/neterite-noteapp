import 'package:flutter/material.dart';

class NeteriteBottomNavigator extends StatelessWidget {
  final int currentIndex;

  const NeteriteBottomNavigator({
    super.key,
    required this.currentIndex, // Index of the selected menu item
  });

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/notes');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/calendar');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/lobby');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/todo');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Highlight the selected item
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.note),
          label: 'notes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),  // Changed to group icon for clarity
          label: 'lobby',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),  // Changed to group icon for clarity
          label: 'todo',
        )
      ],
      type: BottomNavigationBarType.fixed,
      onTap: (index) => _onItemTapped(context, index),
    );
  }
}