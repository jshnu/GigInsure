import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../onboarding/views/onboarding_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  const OtpVerificationScreen({super.key, required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  void _verifyOtp() async {
    if (_otpController.text.length < 4) return;
    setState(() => _isLoading = true);

    // TODO: Verify OTP against FastAPI backend
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    // Navigate to Onboarding after successful login
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.textPrimary)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Verify it's you", style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Enter the 4-digit code sent to +91 ${widget.phone}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 40),

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 32, letterSpacing: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  if (val.length == 4) _verifyOtp(); // Auto-submit when 4 digits entered
                },
              ),

              const SizedBox(height: 24),
              if (_isLoading) const Center(child: CircularProgressIndicator(color: AppColors.accentTeal)),
            ],
          ),
        ),
      ),
    );
  }
}