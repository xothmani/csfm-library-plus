import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/auth/role_chip.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  String _selectedRole = 'Logé';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.registerWithEmailAndPassword(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        isLodged: _selectedRole == 'Logé',
      );
      // Redirection is handled by GoRouter watching auth state
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Center(child: AppLogo(size: 90)),
                const SizedBox(height: 30),
                
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Créer un '),
                      TextSpan(
                        text: 'compte',
                        style: GoogleFonts.playfairDisplay(
                          color: AppTheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez la bibliothèque CSFM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.surface1,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.pushReplacement('/login'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            color: Colors.transparent,
                            child: const Center(
                              child: Text(
                                'Connexion',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Inscription',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),

                // Role Selection
                const Text(
                  'Votre profil',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RoleChip(
                        title: 'Logé',
                        icon: Icons.home_rounded,
                        isSelected: _selectedRole == 'Logé',
                        hasBadge: true,
                        onTap: () => setState(() => _selectedRole = 'Logé'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: RoleChip(
                        title: 'Externe',
                        icon: Icons.school_rounded,
                        isSelected: _selectedRole == 'Externe',
                        onTap: () => setState(() => _selectedRole = 'Externe'),
                      ),
                    ),
                  ],
                ),
                
                // Priority Banner
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _selectedRole == 'Logé' ? null : 0,
                  margin: EdgeInsets.only(top: _selectedRole == 'Logé' ? 16 : 0),
                  padding: _selectedRole == 'Logé' ? const EdgeInsets.all(12) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: AppTheme.goldAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                  ),
                  child: _selectedRole == 'Logé' ? Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppTheme.goldAccent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Les apprenants logés bénéficient d'une priorité de réservation",
                          style: TextStyle(
                            color: AppTheme.goldAccent.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ) : null,
                ),

                const SizedBox(height: 24),
                
                AppTextField(
                  label: 'Nom complet',
                  hint: 'Prénom Nom',
                  prefixIcon: Icons.person_outline,
                  controller: _nameController,
                  validator: (val) => val != null && val.length > 2 
                      ? null 
                      : 'Nom invalide',
                ),
                const SizedBox(height: 20),
                
                AppTextField(
                  label: 'Adresse email',
                  hint: 'nom@csfm.tn',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  validator: (val) => val != null && val.contains('@') 
                      ? null 
                      : 'Email invalide',
                ),
                const SizedBox(height: 20),
                
                AppTextField(
                  label: 'Mot de passe',
                  hint: '8 caractères minimum',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                  validator: (val) => val != null && val.length >= 6 
                      ? null 
                      : 'Mot de passe trop court',
                ),
                const SizedBox(height: 30),
                
                AppButton(
                  text: 'Créer mon compte',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                
                const SizedBox(height: 24),
                
                // Staff Banner
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.textPrimary.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.goldAccent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Compte staff ? Contactez votre administrateur.",
                          style: TextStyle(
                            color: AppTheme.textSecondary.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
