
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_provider.dart';

class Sidebar extends ConsumerStatefulWidget {
  final Widget child;

  const Sidebar({super.key, required this.child});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _hoveredIndex;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final selectedIndex = _getSelectedIndex(context);
    final sidebarWidth = _isCollapsed ? 80 : 280;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Sidebar Navigation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: sidebarWidth.toDouble(),            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surface,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: MouseRegion(
              onEnter: (_) => setState(() {}),
              onExit: (_) => setState(() {}),
              child: CustomScrollView(
                slivers: [
                  // Logo/Header Section
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _animation,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _isCollapsed ? 16 : 24,
                          vertical: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: _isCollapsed
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        colorScheme.primary,
                                        colorScheme.secondary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Symbols.icecream,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                if (!_isCollapsed) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Milkshake Admin',
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: colorScheme.onSurface,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Dashboard',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (!_isCollapsed) ...[
                              const SizedBox(height: 24),
                              // Toggle button
                              GestureDetector(
                                onTap: _toggleSidebar,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Symbols.arrow_back,
                                        size: 16,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Collapse',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: Divider(height: 32, thickness: 1),
                  ),

                  // Navigation Items
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final navItems = _getNavigationItems(context);
                        final item = navItems[index];
                        final isSelected = selectedIndex == index;
                        final isHovered = _hoveredIndex == index;

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _isCollapsed ? 12 : 16,
                            vertical: 2,
                          ),
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _hoveredIndex = index),
                            onExit: (_) => setState(() => _hoveredIndex = null),
                            child: GestureDetector(
                              onTap: () => _onItemTapped(context, index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primaryContainer
                                      : isHovered
                                      ? colorScheme.surfaceContainerHighest
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                    color: colorScheme.primary,
                                    width: 1.5,
                                  )
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                      : null,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: _isCollapsed ? 12 : 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisAlignment: _isCollapsed
                                      ? MainAxisAlignment.center
                                      : MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 20,
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    if (!_isCollapsed) ...[
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                            letterSpacing: isSelected ? 0.2 : 0,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: colorScheme.primary,
                                            boxShadow: [
                                              BoxShadow(
                                                color: colorScheme.primary.withOpacity(0.5),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _getNavigationItems(context).length,
                    ),
                  ),

                  // Spacer
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),

                  // User Profile/Logout Section
                  if (!_isCollapsed)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.1),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colorScheme.secondaryContainer,
                                          colorScheme.tertiaryContainer,
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Symbols.person,
                                      color: colorScheme.onSecondaryContainer,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Admin User',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Administrator',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary.withOpacity(0.1),
                                      colorScheme.secondary.withOpacity(0.1),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextButton.icon(
                                  onPressed: () async {
                                    await ref.read(authProvider.notifier).logout();
                                    if (context.mounted) context.go('/login');
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: colorScheme.error,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Symbols.logout, size: 18),
                                  label: const Text(
                                    'Logout',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Collapsed user info
                  if (_isCollapsed)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.secondaryContainer,
                                    colorScheme.tertiaryContainer,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Symbols.person,
                                color: colorScheme.onSecondaryContainer,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 16),
                            IconButton(
                              onPressed: () async {
                                await ref.read(authProvider.notifier).logout();
                                if (context.mounted) context.go('/login');
                              },
                              icon: Icon(
                                Symbols.logout,
                                color: colorScheme.error,
                                size: 20,
                              ),
                              tooltip: 'Logout',
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
              ),
              child: Stack(
                children: [
                  widget.child,
                  // Expand sidebar button (when collapsed)
                  if (_isCollapsed)
                    Positioned(
                      left: 8,
                      top: 16,
                      child: GestureDetector(
                        onTap: _toggleSidebar,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            Symbols.arrow_forward,
                            size: 20,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<NavigationItem> _getNavigationItems(BuildContext context) {
    return [
      NavigationItem(
        icon: Symbols.dashboard,
        label: 'Dashboard',
        route: '/dashboard',
      ),
      NavigationItem(
        icon: Symbols.icecream,
        label: 'Flavours',
        route: '/flavours',
      ),
      NavigationItem(
        icon: Symbols.sprinkler,
        label: 'Toppings',
        route: '/toppings',
      ),
      NavigationItem(
        icon: Symbols.ad_group,
        label: 'Consistencies',
        route: '/consistencies',
      ),
      NavigationItem(
        icon: Symbols.store,
        label: 'Restaurants',
        route: '/restaurants',
      ),
      NavigationItem(
        icon: Symbols.settings,
        label: 'Config',
        route: '/config',
      ),
      NavigationItem(
        icon: Symbols.receipt_long,
        label: 'Orders Report',
        route: '/orders-report',
      ),
      NavigationItem(
        icon: Symbols.trending_up,
        label: 'Daily Trend',
        route: '/daily-trend',
      ),
      NavigationItem(
        icon: Symbols.history,
        label: 'Audit Logs',
        route: '/audit',
      ),
    ];
  }

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final navItems = _getNavigationItems(context);

    for (int i = 0; i < navItems.length; i++) {
      final route = navItems[i].route;

      if (location == route ||
          location.startsWith('$route/') ||
          (route == '/dashboard' && (location == '/' || location.isEmpty))) {
        return i;
      }
    }
    return 0; // Default to dashboard
  }

  void _onItemTapped(BuildContext context, int index) {
    final navItems = _getNavigationItems(context);
    if (index < navItems.length) {
      context.go(navItems[index].route);
    }
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}