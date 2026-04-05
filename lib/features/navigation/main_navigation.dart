import 'package:flutter/material.dart';

import '../camera/camera_screen.dart';
import '../history/history_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CameraScreen(),
    HistoryScreen(),
  ];

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}

// ================= BOTTOM NAV =================
class _BottomNav extends StatelessWidget {
  final int              currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // ✅ dark green matching app theme
        color: const Color(0xFF0F2A12),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon:       Icons.camera_alt_outlined,
                  activeIcon: Icons.camera_alt,
                  label:      'Scan',
                  isActive:   currentIndex == 0,
                  onTap:      () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon:       Icons.history_outlined,
                  activeIcon: Icons.history,
                  label:      'History',
                  isActive:   currentIndex == 1,
                  onTap:      () => onTap(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= NAV ITEM =================
class _NavItem extends StatelessWidget {
  final IconData     icon;
  final IconData     activeIcon;
  final String       label;
  final bool         isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(
            vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          // ✅ green pill only on active
          color: isActive
              ? Colors.green.shade800.withValues(alpha: 0.9)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: isActive
              ? Border.all(
            color: Colors.green.shade600.withValues(alpha: 0.5),
            width: 1,
          )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [

            // ===== ICON =====
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
                size: 22,
              ),
            ),

            // ===== LABEL — only when active =====
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isActive
                  ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}