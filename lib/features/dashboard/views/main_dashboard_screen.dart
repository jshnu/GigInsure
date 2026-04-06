import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/global_state.dart';
import '../../subscriptions/views/subscription_flow.dart';
import '../providers/disruption_provider.dart';

class MainDashboardScreen extends ConsumerWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final notifier = ref.read(userProvider.notifier);
    final claimState = ref.watch(claimProvider);

    // Calculate dynamic budget details
    double maxMonthlyLimit = user.selectedTier == PlanTier.premium ? 1600.0 : user.selectedTier == PlanTier.standard ? 1200.0 : 800.0;
    double alreadyPaidThisMonth = claimState.history.where((claim) {
      final DateTime cDate = DateTime.parse(claim.timestamp);
      return cDate.year == user.mockDate.year && cDate.month == user.mockDate.month;
    }).fold(0.0, (sum, claim) => sum + claim.amount);
    double remainingBudget = maxMonthlyLimit - alreadyPaidThisMonth;
    double walletBalance = claimState.history.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GigInsure',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            Text("${user.mockDate.day}/${user.mockDate.month}/${user.mockDate.year}",
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.fast_forward, color: AppColors.accentTeal, size: 20),
            tooltip: "Jump to Next Day",
            onPressed: () => notifier.nextDay(),
          ),
          IconButton(
            icon: Icon(user.isDisruptionActive ? Icons.cloud_off : Icons.thunderstorm,
                color: AppColors.alertOrange, size: 20),
            onPressed: () => notifier.toggleDisruption(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // 1. WALLET BALANCE CARD
          _buildBalanceCard(walletBalance),
          const SizedBox(height: 24),

          // 2. ACTIVE POLICY TILE (FULL DETAILS VISIBLE)
          if (user.isSubscribed)
            _buildActivePolicyTile(user, remainingBudget, maxMonthlyLimit)
          else
            _buildUpsellCard(context),

          const SizedBox(height: 24),

          // 3. FILE A CLAIM BUTTON
          _buildFileClaimButton(ref),
          
          const SizedBox(height: 32),

          // 4. SMART ACTIVITY SECTION (REMOVED REDUNDANT POLICY LINK)
          const Text("Your Activity",
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildClaimsCard(context, ref, claimState),
          const SizedBox(height: 40), // Spacing for bottom
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentTeal, Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.accentTeal.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          const Text("Wallet Balance", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text("₹${balance.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  // ENHANCED: Plan details now displayed directly here
  Widget _buildActivePolicyTile(UserState user, double remaining, double total) {
    String planName = user.selectedTier == PlanTier.premium ? "Premium" : user.selectedTier == PlanTier.standard ? "Standard" : "Basic";
    int premium = user.selectedTier == PlanTier.premium ? 79 : user.selectedTier == PlanTier.standard ? 49 : 29;
    double progress = (remaining / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$planName Protection", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₹$premium/wk", style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Remaining coverage", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text("₹${remaining.toStringAsFixed(0)} / ₹${total.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              color: AppColors.accentTeal,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          const Text("Zone: Bengaluru South • 80% Coverage", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFileClaimButton(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          ref.read(userProvider.notifier).setNavIndex(1);
        },
        icon: const Icon(Icons.add_circle_outline, size: 20),
        label: const Text("File a Claim", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardSurface,
          foregroundColor: AppColors.accentTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.accentTeal, width: 1)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildClaimsCard(BuildContext context, WidgetRef ref, ClaimState claimState) {
    final bool hasActiveClaim = claimState.isTriggered && claimState.status != PayoutStatus.disbursed;
    return _dashboardCard(
      title: hasActiveClaim ? "Claim in Progress" : "Recent Claims",
      subtitle: hasActiveClaim 
          ? "Stage: ${claimState.status.name.toUpperCase()}" 
          : "View your claim history",
      icon: Icons.history_edu_outlined,
      iconColor: hasActiveClaim ? AppColors.alertOrange : AppColors.textSecondary,
      ctaLabel: "Details",
      onTap: () => ref.read(userProvider.notifier).setNavIndex(1),
    );
  }

  Widget _dashboardCard({required String title, required String subtitle, required IconData icon, required Color iconColor, required String ctaLabel, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider.withValues(alpha: 0.5))),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ])),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildUpsellCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.divider)),
      child: Column(
        children: [
          const Text("Status: Unprotected", style: TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionFlow())),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal),
              child: const Text("View Protection Plans", style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
