import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/auth/domain/providers/auth_provider.dart';
import 'package:wandermood/features/auth/presentation/screens/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Haal de huidige gebruiker op
    final user = ref.watch(authStateProvider);
    
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFAFF4), // Roze
            Color(0xFFFFF5AF), // Geel
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Jouw Profiel',
                style: GoogleFonts.museoModerno(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
            
            const SizedBox(height: 20),
            
            // Profile Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
                        child: Text(
                          user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Email
                      Text(
                        user?.email ?? 'Niet ingelogd',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Member since
                      Text(
                        'Lid sinds: ${_formatDate(user?.createdAt)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Uitloggen button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _handleSignOut(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Uitloggen',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            
            const SizedBox(height: 30),
            
            // Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: Icons.person,
                      title: 'Bewerk Profiel',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _buildSettingItem(
                      icon: Icons.notifications,
                      title: 'Notificaties',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _buildSettingItem(
                      icon: Icons.lock,
                      title: 'Privacy',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _buildSettingItem(
                      icon: Icons.help,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Onbekend';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}-${date.month}-${date.year}';
    } catch (e) {
      return 'Onbekend';
    }
  }
  
  void _handleSignOut(BuildContext context, WidgetRef ref) async {
    // Toon een bevestigingsdialoog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uitloggen'),
        content: const Text('Weet je zeker dat je wilt uitloggen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuleren'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Uitloggen'),
          ),
        ],
      ),
    );
    
    // Als de gebruiker bevestigt, log dan uit
    if (shouldSignOut == true) {
      await ref.read(authStateProvider.notifier).signOut();
      
      // Navigeer naar het login scherm
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
} 