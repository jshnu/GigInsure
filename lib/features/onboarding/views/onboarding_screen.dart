import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/global_state.dart';
import '../../dashboard/views/dashboard_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _isSuccess = false;
  PlanTier _selectedTier = PlanTier.none;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: !_isSuccess ? AppBar(
        title: const Text("Plan Selection", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ) : null,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Choose your protection",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text("Select a plan that fits your risk profile and earning goals.",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 40),
                  Expanded(
                    child: ListView(
                      children: [
                        _fixedPlanCard(
                          title: "Basic Plan",
                          price: 29,
                          coverage: 800,
                          tier: PlanTier.basic,
                          benefit: "Essential coverage for low-risk routes",
                        ),
                        _fixedPlanCard(
                          title: "Standard Plan",
                          price: 49,
                          coverage: 1200,
                          tier: PlanTier.standard,
                          benefit: "Balanced protection for daily riders",
                          isRecommended: true,
                        ),
                        _fixedPlanCard(
                          title: "Premium Plan",
                          price: 79,
                          coverage: 1600,
                          tier: PlanTier.premium,
                          benefit: "Max security for high-risk conditions",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // LOADING OVERLAY
          if (userState.isLoading)
            Container(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.accentTeal),
                    const SizedBox(height: 32),
                    const Text(
                      "Securing Your Income...",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Establishing parametric coverage thresholds",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // SUCCESS OVERLAY (BETTER THAN BOTTOM SHEET)
          if (_isSuccess)
            _buildSuccessView(),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    String name = _selectedTier == PlanTier.premium ? "Premium" : _selectedTier == PlanTier.standard ? "Standard" : "Basic";
    int coverage = _selectedTier == PlanTier.premium ? 1600 : _selectedTier == PlanTier.standard ? 1200 : 800;
    int price = _selectedTier == PlanTier.premium ? 79 : _selectedTier == PlanTier.standard ? 49 : 29;

    return Container(
      color: AppColors.background,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.verified_user_rounded, color: AppColors.accentTeal, size: 100),
              const SizedBox(height: 32),
              const Text("Protection Active", 
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Your earnings are now secured against environmental disruptions.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    _detailRow("Plan", "$name"),
                    const Divider(color: AppColors.divider, height: 32),
                    _detailRow("Weekly Limit", "₹$coverage"),
                    const Divider(color: AppColors.divider, height: 32),
                    _detailRow("Premium", "₹$price/wk"),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const DashboardHost()), (route) => false),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  child: const Text("Go to Dashboard", style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fixedPlanCard({
    required String title,
    required int price,
    required int coverage,
    required PlanTier tier,
    required String benefit,
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: () => _handlePayment(tier),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isRecommended ? AppColors.accentTeal : AppColors.divider, width: isRecommended ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text("RECOMMENDED", style: TextStyle(color: AppColors.accentTeal, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹$price/wk", style: const TextStyle(color: AppColors.accentTeal, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text("Weekly Coverage: ₹$coverage", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const Divider(height: 24, color: AppColors.divider),
            Text(benefit, style: const TextStyle(color: AppColors.alertOrange, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  void _handlePayment(PlanTier tier) async {
    setState(() => _selectedTier = tier);
    final success = await ref.read(userProvider.notifier).processMockPayment(tier);
    if (success && mounted) {
      setState(() => _isSuccess = true);
    }
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
