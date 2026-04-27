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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event_note_rounded,
                  size: 17, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
            onPressed: () => context.push(RoutePaths.search),
            tooltip: 'Search',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            offset: const Offset(0, 8),
            onSelected: (value) {
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
            itemBuilder: (_) => [
              _menuItem('categories', Icons.category_rounded, AppStrings.categories),
              _menuItem('statistics', Icons.bar_chart_rounded, AppStrings.statistics),
              _menuItem('export', Icons.file_download_outlined, AppStrings.export_),
              const PopupMenuDivider(),
              _menuItem('settings', Icons.settings_rounded, AppStrings.settings),
            ],
          ),
        ],
      ),
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.taskCreate),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _BottomNav(currentIndex: index),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.textSecondary),
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

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  static const _items = [
    (Icons.today_rounded, Icons.today_rounded, AppStrings.today, RoutePaths.today),
    (Icons.view_week_outlined, Icons.view_week_rounded, AppStrings.week, RoutePaths.weekly),
    (Icons.calendar_month_outlined, Icons.calendar_month_rounded, AppStrings.month, RoutePaths.monthly),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final (iconOff, iconOn, label, path) = _items[i];
              final isActive = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.go(path),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isActive ? iconOn : iconOff,
                          size: 22,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
