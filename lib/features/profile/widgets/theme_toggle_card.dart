import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_book_library/config/theme_cubit.dart';

/// Widget wyświetlający przełącznik motywu (jasny/ciemny)
class ThemeToggleCard extends StatelessWidget {
  const ThemeToggleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState == ThemeState.dark;

        return Card(
          elevation: 2,
          child: SwitchListTile(
            secondary: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text(
              'Ciemny motyw',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              isDark ? 'Włączony' : 'Wyłączony',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            value: isDark,
            onChanged: (_) {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        );
      },
    );
  }
}
