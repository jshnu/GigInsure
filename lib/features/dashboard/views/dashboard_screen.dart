import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/global_state.dart';
import 'main_dashboard_screen.dart';
import 'secondary_screens.dart';

class DashboardHost extends ConsumerWidget {
  const DashboardHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final notifier = ref.read(userProvider.notifier);

    // IndexedStack keeps all these screens alive in memory
    final List<Widget> screens = [
      const MainDashboardScreen(),
      const ClaimsScreen(),
      const PayoutHistoryScreen(),
      const PolicyDetailsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: userState.navIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: userState.navIndex,
        onTap: (index) => notifier.setNavIndex(index),
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.accentTeal,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Overview"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Claims"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), label: "Policy"),
        ],
      ),
    );
  }
}