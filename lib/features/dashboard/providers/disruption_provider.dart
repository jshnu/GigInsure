import 'dart:convert';
import 'dart:math';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/global_state.dart';

enum PayoutStatus { idle, checking, detected, calculating, processing, disbursed }

class PastClaim {
  final String date;
  final String type;
  final double amount;
  final String status;
  final String timestamp;

  PastClaim({
    required this.date,
    required this.type,
    required this.amount,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'type': type,
    'amount': amount,
    'status': status,
    'timestamp': timestamp,
  };

  factory PastClaim.fromJson(Map<String, dynamic> json) => PastClaim(
    date: json['date'] as String,
    type: json['type'] as String,
    amount: (json['amount'] as num).toDouble(),
    status: json['status'] as String,
    timestamp: json['timestamp'] as String,
  );
}

class ClaimData {
  final double normalEarnings;
  final double disruptedEarnings;
  final double predictedLoss;
  final double payout;
  final String riskLevel;
  final Map<String, dynamic>? inputs;

  ClaimData({
    required this.normalEarnings,
    required this.disruptedEarnings,
    required this.predictedLoss,
    required this.payout,
    required this.riskLevel,
    this.inputs,
  });

  factory ClaimData.fromJson(Map<String, dynamic> json) {
    return ClaimData(
      normalEarnings: (json['normal_earnings'] as num).toDouble(),
      disruptedEarnings: (json['disrupted_earnings'] as num).toDouble(),
      predictedLoss: (json['final_calculated_loss'] ?? json['predicted_loss'] as num).toDouble(),
      payout: (json['payout'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      inputs: json['input_received'] as Map<String, dynamic>?,
    );
  }
}

class ClaimState {
  final bool isLoading;
  final String? error;
  final ClaimData? data;
  final PayoutStatus status;
  final List<PastClaim> history;
  final bool isTriggered;

  ClaimState({
    this.isLoading = false,
    this.error,
    this.data,
    this.status = PayoutStatus.idle,
    this.history = const [],
    this.isTriggered = false,
  });

  ClaimState copyWith({
    bool? isLoading,
    String? error,
    ClaimData? data,
    PayoutStatus? status,
    List<PastClaim>? history,
    bool? isTriggered,
  }) {
    return ClaimState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
      status: status ?? this.status,
      history: history ?? this.history,
      isTriggered: isTriggered ?? this.isTriggered,
    );
  }
}

class ClaimNotifier extends StateNotifier<ClaimState> {
  ClaimNotifier() : super(ClaimState()) {
    _loadHistory();
  }

  static const String _storageKey = 'giginsure_claims_history';
  static const int _dailyClaimLimit = 2;

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedHistory = prefs.getStringList(_storageKey);
    
    if (storedHistory != null) {
      final history = storedHistory
          .map((item) => PastClaim.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = state.copyWith(history: history);
    }
  }

  Future<void> _saveClaim(PastClaim claim) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentHistory = prefs.getStringList(_storageKey) ?? [];
    
    if (currentHistory.any((item) => PastClaim.fromJson(jsonDecode(item) as Map<String, dynamic>).timestamp == claim.timestamp)) {
      return;
    }

    currentHistory.add(jsonEncode(claim.toJson()));
    await prefs.setStringList(_storageKey, currentHistory);
    
    final updatedHistory = [claim, ...state.history];
    state = state.copyWith(history: updatedHistory);
  }

  void resetClaimFlow() {
    state = state.copyWith(status: PayoutStatus.idle, data: null, isLoading: false, error: null, isTriggered: false);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    state = state.copyWith(history: []);
  }

  Future<void> fetchAndProcessClaim(UserState user) async {
    if (state.status != PayoutStatus.idle) return;

    final DateTime now = user.mockDate;
    
    final claimsToday = state.history.where((claim) {
      final DateTime cDate = DateTime.parse(claim.timestamp);
      return cDate.year == now.year && cDate.month == now.month && cDate.day == now.day;
    }).length;

    if (claimsToday >= _dailyClaimLimit) {
      state = state.copyWith(error: "Daily limit reached ($_dailyClaimLimit/day).", status: PayoutStatus.idle);
      return;
    }

    double maxMonthlyLimit = user.selectedTier == PlanTier.premium ? 3000.0 : user.selectedTier == PlanTier.standard ? 1600.0 : 800.0;
    
    double alreadyPaidThisMonth = state.history.where((claim) {
      final DateTime cDate = DateTime.parse(claim.timestamp);
      return cDate.year == now.year && cDate.month == now.month;
    }).fold(0.0, (sum, claim) => sum + claim.amount);

    double remainingBudget = maxMonthlyLimit - alreadyPaidThisMonth;

    if (remainingBudget <= 0) {
      state = state.copyWith(error: "Monthly coverage limit exhausted.", status: PayoutStatus.idle);
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null, isTriggered: true, status: PayoutStatus.checking);

    try {
      final random = Random();
      final double rain = user.isDisruptionActive ? (60.0 + random.nextDouble() * 40.0) : (random.nextDouble() * 15.0);
      final double traffic = user.isDisruptionActive ? (0.7 + random.nextDouble() * 0.3) : (0.1 + random.nextDouble() * 0.4);
      final double demand = 0.3 + random.nextDouble() * 0.7;

      final payload = {
        "day_of_week": now.weekday - 1, 
        "hour": now.hour,       
        "duration": 4.0,  
        "rain_intensity": rain,
        "traffic_index": traffic,
        "demand_index": demand,
        "zone": random.nextInt(5),
        "coverage_ratio": 0.8,
        "coverage_limit": remainingBudget 
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/calculate-claim'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final data = ClaimData.fromJson(responseData);
        
        final bool isSevere = (rain > 60 || traffic > 0.7);
        final bool isSignificant = data.predictedLoss > 50;

        if (isSevere && isSignificant) {
          state = state.copyWith(isLoading: false, data: data, status: PayoutStatus.detected);
          await Future.delayed(const Duration(seconds: 2));
          state = state.copyWith(status: PayoutStatus.calculating);
          await _simulatePaymentFlow(data, user.mockDate);
        } else {
          state = state.copyWith(isLoading: false, status: PayoutStatus.idle, isTriggered: false, error: "Conditions stable. Loss below threshold.");
        }
      } else {
        state = state.copyWith(isLoading: false, error: "Server error", status: PayoutStatus.idle);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Connection error", status: PayoutStatus.idle);
    }
  }

  Future<void> _simulatePaymentFlow(ClaimData data, DateTime simulatedDate) async {
    await Future.delayed(const Duration(seconds: 3));
    state = state.copyWith(status: PayoutStatus.processing);
    await Future.delayed(const Duration(seconds: 3));
    state = state.copyWith(status: PayoutStatus.disbursed);

    final monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final now = DateTime.now();
    final uniqueTimestamp = DateTime(simulatedDate.year, simulatedDate.month, simulatedDate.day, now.hour, now.minute, now.second, now.millisecond).toIso8601String();

    final newClaim = PastClaim(
      date: "${monthNames[simulatedDate.month - 1]} ${simulatedDate.day}",
      type: data.inputs?['rain_intensity'] != null && (data.inputs!['rain_intensity'] as num) > 50 ? "Severe Rain" : "High Traffic",
      amount: data.payout,
      status: "Paid",
      timestamp: uniqueTimestamp,
    );
    await _saveClaim(newClaim);
  }
}

final claimProvider = StateNotifierProvider<ClaimNotifier, ClaimState>((ref) {
  return ClaimNotifier();
});
