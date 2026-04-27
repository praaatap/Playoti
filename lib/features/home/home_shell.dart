import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/route_names.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(RoutePaths.weekly)) return 1;
    if (location.startsWith(RoutePaths.monthly)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: false,
      appBar: _CupertinoAppBar(
        onSearch: () => context.push(RoutePaths.search),
        onMenuSelected: (value) {
          switch (value) {
            case 'categories':
              context.push(RoutePaths.categories);
            case 'statistics':
              context.push(RoutePaths.statistics);
            case 'export':
              context.push(RoutePaths.export_);
            case 'settings':
              context.push(RoutePaths.settings);
          }
        },
      ),
      body: child,
      floatingActionButton: _CupertinoFAB(
        onPressed: () => context.push(RoutePaths.taskCreate),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _CupertinoBottomNav(currentIndex: index),
    );
  }
}

// ── App Bar ──────────────────────────────────────────────────────────────────

class _CupertinoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearch;
  final ValueChanged<String> onMenuSelected;

  const _CupertinoAppBar({
    required this.onSearch,
    required this.onMenuSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 52 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.85),
            border: const Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              // Logo icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(CupertinoIcons.calendar,
                    size: 15, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              // Search
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: Size.zero,
                onPressed: onSearch,
                child: const Icon(CupertinoIcons.search,
                    size: 22, color: AppColors.textSecondary),
              ),
              // More menu
              _MoreMenu(onSelected: onMenuSelected),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  final ValueChanged<String> onSelected;
  const _MoreMenu({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      icon: const Icon(CupertinoIcons.ellipsis_circle,
          size: 22, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      offset: const Offset(0, 6),
      elevation: 4,
      color: AppColors.surface,
      onSelected: onSelected,
      itemBuilder: (_) => [
        _item('categories', CupertinoIcons.tag, AppStrings.categories),
        _item('statistics', CupertinoIcons.chart_bar, AppStrings.statistics),
        _item('export', CupertinoIcons.arrow_down_to_line, AppStrings.export_),
        const PopupMenuDivider(),
        _item('settings', CupertinoIcons.settings, AppStrings.settings),
      ],
    );
  }

  PopupMenuItem<String> _item(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAB ──────────────────────────────────────────────────────────────────────

class _CupertinoFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const _CupertinoFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(CupertinoIcons.add, color: Colors.white, size: 26),
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _CupertinoBottomNav extends StatelessWidget {
  final int currentIndex;
  const _CupertinoBottomNav({required this.currentIndex});

  static const _items = [
    (CupertinoIcons.sun_max, CupertinoIcons.sun_max_fill,
        AppStrings.today, RoutePaths.today),
    (CupertinoIcons.calendar, CupertinoIcons.calendar,
        AppStrings.week, RoutePaths.weekly),
    (CupertinoIcons.calendar_today, CupertinoIcons.calendar_today,
        AppStrings.month, RoutePaths.monthly),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.divider, width: 0.4)),
          ),
          color: AppColors.background.withValues(alpha: 0.88),
          child: SizedBox(
            height: 56 + bottomPadding,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: List.generate(_items.length, (i) {
                      final (iconOff, iconOn, label, path) = _items[i];
                      final isActive = currentIndex == i;
                      return Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          onPressed: () => context.go(path),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  isActive ? iconOn : iconOff,
                                  key: ValueKey(isActive),
                                  size: isActive ? 26 : 24,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 180),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                                child: Text(label),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: bottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
