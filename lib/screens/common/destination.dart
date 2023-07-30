
import 'package:flutter/material.dart';

class NavDestination extends NavigationDestination {
  final int index;

  const NavDestination({super.key,
    required this.index,
    required super.icon,
    super.selectedIcon,
    required super.label,
    super.tooltip,});
}