import 'package:hooks_riverpod/hooks_riverpod.dart';

enum PlanTier { none, basic, standard, premium }

class RiskProfile {
  final double score;
  final String level;
  final Map<String, double> breakdown;

  RiskProfile({
    required this.score,
    required this.level,
    required this.breakdown,
  });

  factory RiskProfile.initial() => RiskProfile(score: 0, level: "Low", breakdown: {});
}

class UserState {
  final bool isSubscribed;
  final PlanTier selectedTier;
  final int navIndex;
  final bool isLoading;
  final bool isDisruptionActive;
  final DateTime mockDate;
  final RiskProfile riskProfile;

  UserState({
    this.isSubscribed = false,
    this.selectedTier = PlanTier.none,
    this.navIndex = 0,
    this.isLoading = false,
    this.isDisruptionActive = false,
    DateTime? mockDate,
    RiskProfile? riskProfile,
  })  : mockDate = mockDate ?? DateTime.now(),
        riskProfile = riskProfile ?? RiskProfile.initial();

  UserState copyWith({
    bool? isSubscribed,
    PlanTier? selectedTier,
    int? navIndex,
    bool? isLoading,
    bool? isDisruptionActive,
    DateTime? mockDate,
    RiskProfile? riskProfile,
  }) {
    return UserState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      selectedTier: selectedTier ?? this.selectedTier,
      navIndex: navIndex ?? this.navIndex,
      isLoading: isLoading ?? this.isLoading,
      isDisruptionActive: isDisruptionActive ?? this.isDisruptionActive,
      mockDate: mockDate ?? this.mockDate,
      riskProfile: riskProfile ?? this.riskProfile,
    );
  }
}

class RiskScoringService {
  static RiskProfile calculate({
    required String vehicleType,
    required double hoursPerDay,
    required double dailyEarnings,
  }) {
    // 1. VEHICLE RISK
    double vehicleRisk = vehicleType.toLowerCase() == "bicycle"
        ? 1.0
        : vehicleType.toLowerCase() == "scooter"
            ? 0.6
            : 0.3;

    // 2. HOURS RISK (More hours = lower risk)
    double hoursRisk = (1 - (hoursPerDay / 14)).clamp(0.0, 1.0);

    // 3. EARNINGS RISK (Higher earnings = lower risk)
    double earningsRisk = (1 - (dailyEarnings / 2000)).clamp(0.0, 1.0);

    // 4. FINAL SCORE
    double finalScore = (vehicleRisk * 0.4) + (hoursRisk * 0.3) + (earningsRisk * 0.3);
    finalScore = finalScore.clamp(0.0, 1.0);

    // 5. MAP TO LEVEL
    String level = finalScore <= 0.3
        ? "Low"
        : finalScore <= 0.7
            ? "Medium"
            : "High";

    return RiskProfile(
      score: finalScore,
      level: level,
      breakdown: {
        "vehicle": vehicleRisk,
        "hours": hoursRisk,
        "earnings": earningsRisk,
      },
    );
  }
}

class EarningsService {
  static Map<String, dynamic> calculate(bool isDisrupted) {
    double baseEarnings = 1200.0;
    if (isDisrupted) {
      return {
        "min": (baseEarnings * 0.6).round(),
        "max": (baseEarnings * 1.5).round(),
        "risk": "High Risk",
      };
    } else {
      return {
        "min": baseEarnings.round(),
        "max": (baseEarnings * 1.2).round(),
        "risk": "Low Risk",
      };
    }
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  void setNavIndex(int index) => state = state.copyWith(navIndex: index);

  void toggleDisruption() {
    state = state.copyWith(isDisruptionActive: !state.isDisruptionActive);
  }

  void nextDay() {
    state = state.copyWith(
      mockDate: state.mockDate.add(const Duration(days: 1)),
      isDisruptionActive: false,
    );
  }

  void setRiskProfile(RiskProfile profile) {
    state = state.copyWith(riskProfile: profile);
  }

  Future<bool> processMockPayment(PlanTier tier) async {
    state = state.copyWith(isLoading: true);
    // Simulate Razorpay Sandbox delay
    await Future.delayed(const Duration(seconds: 3));
    state = state.copyWith(
      isSubscribed: true,
      selectedTier: tier,
      navIndex: 0,
      isLoading: false,
    );
    return true;
  }

  Future<bool> activateSubscription(PlanTier tier) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isSubscribed: true, selectedTier: tier, navIndex: 0, isLoading: false);
    return true;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
