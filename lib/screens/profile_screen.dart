import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/change_password_sheet.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/local_storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChangePasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final dbService = Provider.of<DatabaseService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      body: userId == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<Map<String, dynamic>?>(
              stream: dbService.getUserProfile(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final profile = snapshot.data;
                final name = profile?['name'] ?? 'User';
                final email =
                    profile?['email'] ?? authService.currentUser?.email ?? '';

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
                        // Hero Profile Section
                        Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Theme.of(context).primaryColor,
                              ),
                            ).animate().scale(
                              delay: 200.ms,
                              curve: Curves.easeOutBack,
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child:
                                  Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                          ),
                                          Text(
                                            email,
                                            style: const TextStyle(
                                              color: Color(0xFF50606D),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              _buildBadge(
                                                'Administrator',
                                                const Color(0xFFD1E2F1),
                                                const Color(0xFF00425E),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                      .animate()
                                      .fadeIn(delay: 300.ms)
                                      .slideX(begin: 0.1),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Stats Overview
                        StreamBuilder<List>(
                          stream: dbService.getProducts(userId),
                          builder: (context, prodSnapshot) {
                            final count = prodSnapshot.data?.length ?? 0;
                            return Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatItem(
                                        'Items Tracked',
                                        '$count',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildStatItem(
                                        'System Status',
                                        'Active',
                                      ),
                                    ),
                                  ],
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.1);
                          },
                        ),

                        const SizedBox(height: 40),

                        // Menu Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0, bottom: 16),
                              child: Text(
                                'ACCOUNT OVERVIEW',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF50606D),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showChangePasswordSheet(context),
                              child: _buildMenuItem(
                                Icons.manage_accounts,
                                'Account Settings',
                                'Security, change password, and privacy',
                              ),
                            ),
                            const _NotificationMenuItem(),
                            _buildMenuItem(
                              Icons.help_outline,
                              'Help Center (Coming Soon)',
                              'Documentation and support',
                            ),
                          ],
                        ).animate().fadeIn(delay: 500.ms),

                        const SizedBox(height: 40),

                        // Action Section
                        const Divider(color: Color(0xFFEDEEEF)),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: () async {
                            await authService.signOut();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.logout,
                            color: Color(0xFFBA1A1A),
                          ),
                          label: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Color(0xFFBA1A1A),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: const Color(
                              0xFFFFDAD6,
                            ).withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ).animate().fadeIn(delay: 600.ms),

                        const SizedBox(height: 32),
                        const Text(
                          'Version 2.4.0 (Build 992)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF70787E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 24, top: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              ),
              child: _buildNavItem(context, Icons.grid_view, 'Home', false),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/add_product'),
              child: _buildNavItem(
                context,
                Icons.add_circle_outline,
                'Add',
                false,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
              child: _buildNavItem(context, Icons.person, 'Profile', true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEEEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF50606D),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF00425E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle, {
    bool hasBadge = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00425E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF191C1D),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF50606D),
                  ),
                ),
              ],
            ),
          ),
          if (hasBadge)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFBA1A1A),
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 16),
          const Icon(Icons.chevron_right, color: Color(0xFFC0C7CE)),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool active,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFD1E2F1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active
                ? Theme.of(context).primaryColor
                : const Color(0xFF70787E),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: active
                  ? Theme.of(context).primaryColor
                  : const Color(0xFF70787E),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationMenuItem extends StatefulWidget {
  const _NotificationMenuItem({super.key});

  @override
  State<_NotificationMenuItem> createState() => _NotificationMenuItemState();
}

class _NotificationMenuItemState extends State<_NotificationMenuItem> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final value = await LocalStorageService().getNotificationPreference();
    if (mounted) setState(() => _notificationsEnabled = value);
  }

  Future<void> _toggle(bool value) async {
    if (mounted) setState(() => _notificationsEnabled = value);
    await LocalStorageService().saveNotificationPreference(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: Color(0xFF00425E),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF191C1D),
                  ),
                ),
                Text(
                  'Local Device Preference',
                  style: TextStyle(fontSize: 12, color: Color(0xFF50606D)),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: _toggle,
            activeColor: const Color(0xFF00425E),
          ),
        ],
      ),
    );
  }
}
