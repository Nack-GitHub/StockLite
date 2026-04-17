import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/stock_lite_button.dart';
import '../widgets/stock_lite_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
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
      body: Row(
        children: [
          // Left Panel (Branding) - Hidden on mobile
          if (MediaQuery.of(context).size.width >= 1024)
            Expanded(
              flex: 7,
              child: Container(
                color: Theme.of(context).primaryColor,
                padding: const EdgeInsets.all(48),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBujhmxzEwENYHUueUgo0FAuUIvawWqwwjf0oLsb5R7htSA4dbGvXSGJBUPtsxciW4TXLO-enKUKcNYYH3zI3Cak1z_Lg-0TZob0vfVoGGefmBLaYJXR-8PQu63nSXUH-sQKkMugmfZT_4KEZYE5IWl8S4ipVipNRTUBwcA8pcfR_xaI2vFptgeduXmVk2QcVBNy5iaDTeS2caa9TYRxgvVxXEwncJrZIPUVjQkoT7FGUA97sAQ_B1l66N_LRvMN7jivE5M1ow85lU',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2, color: Colors.white, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'StockLite',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Master your inventory with absolute precision.',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: Colors.white,
                                    fontSize: 48,
                                  ),
                            ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
                            const SizedBox(height: 24),
                            Text(
                              'Designed for high-performance teams who value clarity over chaos. Transform your warehouse into a sanctuary of efficiency.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 18,
                                  ),
                            ).animate().fadeIn(delay: 400.ms),
                          ],
                        ),
                        const SizedBox(),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(),
            ),

          // Right Panel (Form)
          Expanded(
            flex: 5,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (MediaQuery.of(context).size.width < 1024) ...[
                          Row(
                            children: [
                              Icon(Icons.inventory_2, color: Theme.of(context).primaryColor, size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'StockLite',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w900,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                        ],

                        Text('Welcome Back', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn().slideY(begin: 0.1),
                        const SizedBox(height: 8),
                        Text('Please sign in to access your dashboard.', style: Theme.of(context).textTheme.bodyMedium).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 48),

                        StockLiteInput(
                          label: 'Work Email',
                          hintText: 'name@company.com',
                          prefixIcon: Icons.mail_outline,
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your email';
                            if (!value.contains('@')) return 'Please enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PASSWORD',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                    color: const Color(0xFF50606D),
                                  ),
                            ),
                            TextButton(onPressed: () {}, child: const Text('Forgot Password?')),
                          ],
                        ),
                        StockLiteInput(
                          label: '',
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          isPassword: _obscurePassword,
                          controller: _passwordController,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your password';
                            if (value.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : StockLiteButton(
                                text: 'Sign In',
                                onPressed: _handleLogin,
                                icon: Icons.arrow_forward,
                              ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.easeOutBack),

                        const SizedBox(height: 48),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/signup'),
                            child: Text.rich(
                              TextSpan(
                                text: 'New to the precision workflow? ',
                                style: Theme.of(context).textTheme.bodySmall,
                                children: [
                                  TextSpan(
                                    text: 'Sign up',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
