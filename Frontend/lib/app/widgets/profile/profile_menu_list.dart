import 'package:flutter/material.dart';
import 'profile_components.dart';

class ProfileMenuEntry {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final Color? iconColor;

  const ProfileMenuEntry({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.iconColor,
  });
}

class ProfileMenuList extends StatelessWidget {
  final List<ProfileMenuEntry> entries;

  const ProfileMenuList({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in entries)
          ProfileMenuItem(
            icon: entry.icon,
            title: entry.title,
            onTap: entry.onTap,
            isDestructive: entry.isDestructive,
            iconColor: entry.iconColor,
          ),
      ],
    );
  }
}
