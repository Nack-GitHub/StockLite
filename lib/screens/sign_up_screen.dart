import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/stock_lite_button.dart';
import '../widgets/stock_lite_input.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Precision Requirement'),
          content: const Text('Please agree to total precision terms before proceeding.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        onCreateProfile: (uid, name, email) => dbService.createUserProfile(uid, name, email),
      );

      if (mounted) Navigator.pop(context); // Go back to login
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 28),
                const SizedBox(width: 12),
                const Text('Sign Up Failed'),
              ],
            ),
            content: Text(
              e.toString().replaceAll(RegExp(r'\[.*\] '), ''),
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background/Branding
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF3F4F5),
              child: Opacity(
                opacity: 0.03,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBujhmxzEwENYHUueUgo0FAuUIvawWqwwjf0oLsb5R7htSA4dbGvXSGJBUPtsxciW4TXLO-enKUKcNYYH3zI3Cak1z_Lg-0TZob0vfVoGGefmBLaYJXR-8PQu63nSXUH-sQKkMugmfZT_4KEZYE5IWl8S4ipVipNRTUBwcA8pcfR_xaI2vFptgeduXmVk2QcVBNy5iaDTeS2caa9TYRxgvVxXEwncJrZIPUVjQkoT7FGUA97sAQ_B1l66N_LRvMN7jivE5M1ow85lU',
                  fit: BoxFit.cover,
                ),
              ),
            ).animate().fadeIn(duration: 1.seconds),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).primaryColor,
                            ),
                      ).animate().fadeIn().slideY(begin: 0.1),
                      const SizedBox(height: 8),
                      Text(
                        'Join StockLite to streamline your inventory management.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 40),

                      StockLiteInput(
                        label: 'Full Name',
                        hintText: 'John Doe',
                        prefixIcon: Icons.person_outline,
                        controller: _nameController,
                        validator: (value) => (value == null || value.isEmpty) ? 'Please enter your full name' : null,
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                      const SizedBox(height: 24),

                      StockLiteInput(
                        label: 'Work Email',
                        hintText: 'john@company.com',
                        prefixIcon: Icons.mail_outline,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email';
                          if (!value.contains('@')) return 'Please enter a valid email';
                          return null;
                        },
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                      const SizedBox(height: 24),

                      StockLiteInput(
                        label: 'Password',
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a password';
                          if (value.length < 8) return 'Password must be at least 8 characters';
                          if (value.length > 16) return 'Password must not exceed 16 characters';
                          if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])').hasMatch(value)) {
                            return 'Include uppercase, lowercase, number, and special character';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                      const SizedBox(height: 24),

                      StockLiteInput(
                        label: 'Confirm Password',
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_reset_outlined,
                        isPassword: true,
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                      const SizedBox(height: 24),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              activeColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _agreedToTerms = val ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'I agree to the ',
                                style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF40484E)),
                                children: [
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(color: Color(0xFF00425E), fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(color: Color(0xFF00425E), fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 700.ms),

                      const SizedBox(height: 40),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : StockLiteButton(
                              text: 'Sign Up',
                              onPressed: _handleSignUp,
                              icon: Icons.arrow_forward,
                            ).animate().scale(delay: 800.ms, duration: 400.ms, curve: Curves.easeOutBack),

                      const SizedBox(height: 48),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
