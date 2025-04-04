import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/core/presentation/widgets/swirl_background.dart';
import 'package:wandermood/features/profile/domain/providers/profile_provider.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return SwirlBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Privacy Settings',
            style: GoogleFonts.poppins(
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: profileAsync.when(
          data: (profile) => ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Profile Visibility
                    SwitchListTile(
                      title: Text(
                        'Public Profile',
                        style: GoogleFonts.poppins(),
                      ),
                      subtitle: Text(
                        'Allow others to view your profile',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      value: profile?.isPublic ?? true,
                      activeColor: const Color(0xFF4CAF50),
                      onChanged: (value) async {
                        try {
                          await ref.read(profileProvider.notifier).updateProfile(
                            isPublic: value,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Profile visibility updated',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: const Color(0xFF4CAF50),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to update privacy settings: ${e.toString()}',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 1),
                    // Push Notifications
                    SwitchListTile(
                      title: Text(
                        'Push Notifications',
                        style: GoogleFonts.poppins(),
                      ),
                      subtitle: Text(
                        'Receive push notifications',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      value: profile?.notificationPreferences['push'] ?? true,
                      activeColor: const Color(0xFF4CAF50),
                      onChanged: (value) async {
                        try {
                          final newPrefs = Map<String, bool>.from(
                            profile?.notificationPreferences ?? {'push': true, 'email': true},
                          );
                          newPrefs['push'] = value;
                          
                          await ref.read(profileProvider.notifier).updateProfile(
                            notificationPreferences: newPrefs,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Push notifications ${value ? 'enabled' : 'disabled'}',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: const Color(0xFF4CAF50),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to update notification settings: ${e.toString()}',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 1),
                    // Email Notifications
                    SwitchListTile(
                      title: Text(
                        'Email Notifications',
                        style: GoogleFonts.poppins(),
                      ),
                      subtitle: Text(
                        'Receive email notifications',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      value: profile?.notificationPreferences['email'] ?? true,
                      activeColor: const Color(0xFF4CAF50),
                      onChanged: (value) async {
                        try {
                          final newPrefs = Map<String, bool>.from(
                            profile?.notificationPreferences ?? {'push': true, 'email': true},
                          );
                          newPrefs['email'] = value;
                          
                          await ref.read(profileProvider.notifier).updateProfile(
                            notificationPreferences: newPrefs,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Email notifications ${value ? 'enabled' : 'disabled'}',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: const Color(0xFF4CAF50),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to update notification settings: ${e.toString()}',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Manage your privacy settings and notification preferences. These settings control who can see your profile and how you receive updates.',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Error loading privacy settings',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
} 