import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_logo.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Animated Logo
              const AppLogo(size: 130),
              const SizedBox(height: 40),
              
              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  children: [
                    const TextSpan(text: 'CSFM '),
                    TextSpan(
                      text: 'Library+',
                      style: GoogleFonts.playfairDisplay(
                        color: AppTheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Tagline
              const Text(
                'Votre bibliothèque scolaire,\nnumérique et intelligente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              
              const Spacer(),
              
              // Action Buttons
              AppButton(
                text: 'Commencer',
                onPressed: () => context.push('/register'),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: "J'ai déjà un compte",
                isPrimary: false,
                onPressed: () => context.push('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
