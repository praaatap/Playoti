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
    if (location.startsWith(RoutePaths.notes)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final primary = Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: false,
      appBar: _CupertinoAppBar(
        onSearch: () => context.push(RoutePaths.search),
        onMenuSelected: (value) {
          switch (value) {
            case 'categories':
              context.push(RoutePaths.categories);
            case 'statistics':
              context.push(RoutePaths.statistics);
            case 'templates':
              context.push(RoutePaths.templates);
            case 'export':
              context.push(RoutePaths.export_);
            case 'settings':
              context.push(RoutePaths.settings);
          }
        },
      ),
      body: child,
      floatingActionButton: _CupertinoFAB(
        color: primary,
        onPressed: () => index == 3
            ? context.push(RoutePaths.noteCreate)
            : context.push(RoutePaths.taskCreate),
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
    final primary = Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 52 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.85),
            border: const Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: primary,
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
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: Size.zero,
                onPressed: onSearch,
                child: const Icon(CupertinoIcons.search,
                    size: 22, color: AppColors.textSecondary),
              ),
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
        _item('statistics', CupertinoIcons.chart_bar, AppStrings.statistics),
        _item('categories', CupertinoIcons.tag, AppStrings.categories),
        _item('templates', CupertinoIcons.list_bullet_below_rectangle,
            AppStrings.templates),
        const PopupMenuDivider(),
        _item('settings', CupertinoIcons.settings, AppStrings.settings),
        _item('export', CupertinoIcons.arrow_down_to_line, AppStrings.export_),
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
  final Color color;
  const _CupertinoFAB({required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
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
    (CupertinoIcons.doc_text, CupertinoIcons.doc_text_fill,
        AppStrings.notes, RoutePaths.notes),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border:
                const Border(top: BorderSide(color: AppColors.divider, width: 0.4)),
          ),
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? primary.withValues(alpha: 0.10)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
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
                                        ? primary
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
                                        ? primary
                                        : AppColors.textTertiary,
                                  ),
                                  child: Text(label),
                                ),
                              ],
                            ),
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
