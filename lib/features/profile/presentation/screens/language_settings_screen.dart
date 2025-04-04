import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/core/presentation/widgets/swirl_background.dart';
import 'package:wandermood/features/profile/domain/providers/profile_provider.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

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
            'Language Settings',
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
                    _buildLanguageOption(
                      context,
                      ref,
                      'English',
                      'en',
                      profile?.languagePreference ?? 'en',
                    ),
                    const Divider(height: 1),
                    _buildLanguageOption(
                      context,
                      ref,
                      'Nederlands',
                      'nl',
                      profile?.languagePreference ?? 'en',
                    ),
                    const Divider(height: 1),
                    _buildLanguageOption(
                      context,
                      ref,
                      'Español',
                      'es',
                      profile?.languagePreference ?? 'en',
                    ),
                    const Divider(height: 1),
                    _buildLanguageOption(
                      context,
                      ref,
                      'Français',
                      'fr',
                      profile?.languagePreference ?? 'en',
                    ),
                    const Divider(height: 1),
                    _buildLanguageOption(
                      context,
                      ref,
                      'Deutsch',
                      'de',
                      profile?.languagePreference ?? 'en',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose your preferred language for the app interface. This will affect all text and content throughout the app.',
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
              'Error loading language settings',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String language,
    String code,
    String currentLanguage,
  ) {
    final isSelected = currentLanguage == code;

    return ListTile(
      title: Text(
        language,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF4CAF50))
          : null,
      onTap: () async {
        try {
          await ref.read(profileProvider.notifier).updateProfile(
            languagePreference: code,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Language updated to $language',
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
                  'Failed to update language: ${e.toString()}',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }
} 