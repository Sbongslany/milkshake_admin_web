
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/sidebar.dart';
import '../../features/auth/auth_provider.dart'; // Import auth provider

class DashboardPage extends ConsumerWidget {
  final Widget child;

  const DashboardPage({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milkshake Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Perform logout: clear token & state
              await ref.read(authProvider.notifier).logout();

              // Redirect to login (router guard will prevent access to protected routes)
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Sidebar(child: child),
    );
  }
}