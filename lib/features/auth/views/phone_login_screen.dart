import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart'; // Assume this has our Slate/Teal colors
import 'otp_verification_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _sendOtp() async {
    if (_phoneController.text.length < 10) return;
    setState(() => _isLoading = true);

    // TODO: Call your FastAPI backend here to trigger SMS
    await Future.delayed(const Duration(seconds: 1)); // Simulating network

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.push(context, MaterialPageRoute(builder: (_) => OtpVerificationScreen(phone: _phoneController.text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.shield_rounded, color: AppColors.accentTeal, size: 48),
              const SizedBox(height: 24),
              const Text("Enter your phone number", style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              const Text("We'll send you a secure OTP to verify your account.", style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 40),

              // Phone Input Field
              Container(
                decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text("+91", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 24, color: AppColors.divider),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, letterSpacing: 2),
                        decoration: const InputDecoration(border: InputBorder.none, counterText: "", hintText: "00000 00000", hintStyle: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.background)
                      : const Text("Continue", style: TextStyle(color: AppColors.background, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}