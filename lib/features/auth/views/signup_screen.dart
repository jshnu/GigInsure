import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../onboarding/views/onboarding_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _govtIdNumberController = TextEditingController();
  final TextEditingController _partnerIdController = TextEditingController();
  
  String? _selectedApp;
  String? _selectedIdType;
  final List<String> _deliveryApps = ['Swiggy', 'Zomato'];
  final List<String> _idTypes = ['Aadhaar', 'PAN'];
  
  bool _isLoading = false;

  void _signUp() async {
    // Simplified UI-only signup
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.shield_rounded, color: AppColors.accentTeal, size: 48),
              const SizedBox(height: 24),
              const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Join GigInsure to protect your earnings against weather disruptions.",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              _buildInputField(
                controller: _nameController,
                label: "Full Name",
                hint: "Enter your legal name",
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _phoneController,
                label: "Phone Number",
                hint: "00000 00000",
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _passwordController,
                label: "Password",
                hint: "••••••••",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: "Identification Type",
                hint: "Select ID Type",
                value: _selectedIdType,
                items: _idTypes,
                icon: Icons.badge_outlined,
                onChanged: (val) => setState(() => _selectedIdType = val),
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _govtIdNumberController,
                label: "ID Number",
                hint: "Enter ID number",
                icon: Icons.numbers_rounded,
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: "Delivery App",
                hint: "Select platform",
                value: _selectedApp,
                items: _deliveryApps,
                icon: Icons.delivery_dining_outlined,
                onChanged: (val) => setState(() => _selectedApp = val),
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _partnerIdController,
                label: "Partner ID",
                hint: "Enter your rider unique ID",
                icon: Icons.assignment_ind_outlined,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.background)
                      : const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: RichText(
                    text: const TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            color: AppColors.accentTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF475569)),
            prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 22),
            filled: true,
            fillColor: AppColors.cardSurface,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          dropdownColor: AppColors.cardSurface,
          value: value,
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF475569)),
            prefixIcon: Icon(icon, color: AppColors.accentTeal, size: 22),
            filled: true,
            fillColor: AppColors.cardSurface,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accentTeal, width: 2),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}