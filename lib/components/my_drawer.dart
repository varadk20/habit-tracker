import 'package:flutter/material.dart';
import 'package:habit_tracker/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

@override
Widget build(BuildContext context) {
  return Drawer(
    backgroundColor: Theme.of(context).colorScheme.surface,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Modes of Light',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Switch(
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            onChanged: (value) => 
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          ),
        ],
      ),
    ),
  );
}
}