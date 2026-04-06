import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/global_state.dart';
import '../providers/disruption_provider.dart';

// --- CLAIMS SCREEN ---
class ClaimsScreen extends ConsumerStatefulWidget {
  const ClaimsScreen({super.key});

  @override
  ConsumerState<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends ConsumerState<ClaimsScreen> {
  String? _selectedCategory;
  final List<String> _categories = [
    'Weather Claim',
    'Traffic Congestion Claim',
    'Civic Claim'
  ];

  final TextEditingController _orderIdController = TextEditingController();
  String? _selectedDuration;
  final List<String> _durations = [
    '6 to 7 PM',
    '7 to 8 PM',
    '8 to 9 PM',
    '9 to 10 PM'
  ];

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final claimState = ref.watch(claimProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("File a Claim", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: !user.isSubscribed
          ? const Center(child: Text("Activate a plan to file claims.", style: TextStyle(color: AppColors.textSecondary)))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // 1. CLAIM CATEGORY
                const Text("Claim Category", style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      dropdownColor: AppColors.cardSurface,
                      isExpanded: true,
                      hint: const Text("Select Category", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. ORDER ID (Only for Traffic Congestion)
                if (_selectedCategory == 'Traffic Congestion Claim') ...[
                  const Text("Order ID", style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _orderIdController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter your active Order ID",
                      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.cardSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 3. DURATION SELECTION (TOGGLE TILES)
                const Text("Claim Duration", style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _durations.map((duration) {
                    bool isSelected = _selectedDuration == duration;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDuration = duration),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accentTeal.withValues(alpha: 0.1) : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppColors.accentTeal : AppColors.divider.withValues(alpha: 0.5)),
                        ),
                        child: Text(duration, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                // 4. PREVIOUS CLAIM CHECK STEPS (VERTICAL TIMELINE)
                if (claimState.isTriggered && claimState.status != PayoutStatus.disbursed) ...[
                  const Text("Claim Verification Status", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _ClaimTimeline(status: claimState.status, data: claimState.data),
                  const SizedBox(height: 32),
                ] else if (claimState.isLoading) ...[
                  const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: AppColors.accentTeal))),
                  const SizedBox(height: 32),
                ] else ...[
                  // 5. ACTION BUTTON (Only show if not currently triggered)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_selectedCategory == null || _selectedDuration == null) 
                          ? null 
                          : () => ref.read(claimProvider.notifier).fetchAndProcessClaim(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: AppColors.divider,
                      ),
                      child: const Text("Run Payout Engine", style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
                
                if (claimState.status == PayoutStatus.disbursed) ...[
                  const SizedBox(height: 24),
                  _buildSuccessCard(ref),
                ],

                const SizedBox(height: 32),
                const Text("Recent Claims", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (claimState.history.isEmpty)
                  const Center(child: Text("No transactions yet", style: TextStyle(color: AppColors.textSecondary)))
                else
                  ...claimState.history.map((claim) => _buildHistoryItem(claim)),
              ],
            ),
    );
  }

  Widget _buildHistoryItem(PastClaim claim) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(claim.type, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(claim.date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ]),
          Text("₹${claim.amount.toStringAsFixed(0)}", style: const TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSuccessCard(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accentTeal)),
      child: Column(
        children: [
          const Icon(Icons.verified, color: AppColors.accentTeal, size: 48),
          const SizedBox(height: 16),
          const Text("Payout Disbursed!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextButton(onPressed: () { ref.read(claimProvider.notifier).resetClaimFlow(); }, child: const Text("New Claim", style: TextStyle(color: AppColors.accentTeal, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

// --- VERTICAL STEPPER COMPONENT (RESTORED) ---
class _ClaimTimeline extends StatelessWidget {
  final PayoutStatus status;
  final ClaimData? data;
  const _ClaimTimeline({required this.status, this.data});

  @override
  Widget build(BuildContext context) {
    final stages = ["Scanning Conditions", "Loss Calculated", "Payout Processing", "Funds Disbursed"];
    
    int currentStage = 0;
    if (status == PayoutStatus.detected) currentStage = 0;
    if (status == PayoutStatus.calculating) currentStage = 1;
    if (status == PayoutStatus.processing) currentStage = 2;
    if (status == PayoutStatus.disbursed) currentStage = 3;

    final descriptions = [
      status == PayoutStatus.checking 
          ? "Syncing with environmental sensors..." 
          : "System identified conditions meeting policy triggers.",
      data != null 
          ? "Loss of ₹${data!.predictedLoss.toStringAsFixed(0)} calculated. Risk: ${data!.riskLevel}."
          : "Calculating delta between normal and disrupted earnings...",
      data != null 
          ? "Initiating ₹${data!.payout.toStringAsFixed(0)} transfer to your wallet."
          : "Preparing payment gateway disbursement...",
      "Credited to your linked bank account."
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(stages.length, (index) {
          bool isCompleted = index < currentStage || (index == currentStage && status != PayoutStatus.checking);
          bool isScanning = index == 0 && status == PayoutStatus.checking;
          bool isLast = index == stages.length - 1;
          bool isActive = index == currentStage;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.accentTeal : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: isCompleted ? AppColors.accentTeal : AppColors.divider, width: 2),
                        boxShadow: (isActive || isScanning) ? [const BoxShadow(color: AppColors.accentTeal, blurRadius: 8)] : [],
                      ),
                      child: isCompleted 
                          ? const Icon(Icons.check, size: 12, color: AppColors.background)
                          : isScanning ? const Padding(padding: EdgeInsets.all(4), child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentTeal)) : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isCompleted && index < currentStage ? AppColors.accentTeal : AppColors.divider.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stages[index], 
                            style: TextStyle(color: isCompleted ? Colors.white : AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(descriptions[index], style: TextStyle(color: AppColors.textSecondary.withValues(alpha: isCompleted ? 1.0 : 0.5), fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// --- PLACEHOLDER SCREENS FOR HOST ---
class PayoutHistoryScreen extends StatelessWidget {
  const PayoutHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: AppColors.background, body: Center(child: Text("Wallet UI", style: TextStyle(color: Colors.white))));
}

class PolicyDetailsScreen extends StatelessWidget {
  const PolicyDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: AppColors.background, body: Center(child: Text("Policy Details UI", style: TextStyle(color: Colors.white))));
}
