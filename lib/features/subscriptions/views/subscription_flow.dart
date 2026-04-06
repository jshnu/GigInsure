import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/global_state.dart';

class SubscriptionFlow extends ConsumerWidget {
  const SubscriptionFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Choose Protection"), backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text("Select a plan to cover your gig earnings.", style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 24),
              _buildPlanCard(context, ref, "Basic Plan", 29, 800, PlanTier.basic, "Low risk zones"),
              _buildPlanCard(context, ref, "Standard Plan", 49, 1200, PlanTier.standard, "Recommended for Bangalore", isRecommended: true),
              _buildPlanCard(context, ref, "Premium Plan", 79, 1600, PlanTier.premium, "High volatility areas"),
            ],
          ),
          if (userState.isLoading)
            Container(
              color: AppColors.background.withValues(alpha: 0.8),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.accentTeal),
                    SizedBox(height: 16),
                    Text("Processing Payment Securely...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, String title, int price, int limit, PlanTier tier, String desc, {bool isRecommended = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isRecommended ? AppColors.accentTeal : AppColors.divider, width: isRecommended ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final success = await ref.read(userProvider.notifier).activateSubscription(tier);
            if (success && context.mounted) {
              Navigator.pop(context); // Return to dashboard on success
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRecommended)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Text("RECOMMENDED", style: TextStyle(color: AppColors.accentTeal, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("₹$price/wk", style: const TextStyle(color: AppColors.accentTeal, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Max Coverage: ₹$limit", style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const Divider(height: 24, color: AppColors.divider),
                Text(desc, style: const TextStyle(color: AppColors.alertOrange, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}