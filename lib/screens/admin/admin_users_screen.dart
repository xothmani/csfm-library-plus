import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/admin_providers.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(allUsersAdminProvider).value ?? [];
    final query = ref.watch(adminUserSearchProvider);
    final filtered = query.isEmpty ? allUsers : allUsers.where((u) => u.fullName.toLowerCase().contains(query.toLowerCase()) || u.email.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Utilisateurs', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold))),
                  GestureDetector(
                    onTap: () => _showCreateStaffSheet(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.purple, AppColors.accent]), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => ref.read(adminUserSearchProvider.notifier).set(v),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur...', hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                  filled: true, fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 6),
              child: Align(alignment: Alignment.centerLeft, child: Text('${filtered.length} utilisateur(s)', style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('Aucun utilisateur', style: TextStyle(color: AppColors.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _UserItem(
                        user: filtered[i],
                        onToggleActive: () => _toggleActive(filtered[i]),
                        onViewDetail: () => _showUserDetail(context, filtered[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleActive(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'isActive': !user.isActive});
  }

  void _showUserDetail(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _UserDetailSheet(user: user),
    );
  }

  void _showCreateStaffSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _CreateStaffSheet(),
    );
  }
}

class _UserItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onToggleActive;
  final VoidCallback onViewDetail;
  const _UserItem({required this.user, required this.onToggleActive, required this.onViewDetail});

  Color get _roleColor {
    switch (user.role) {
      case 'Administrateur': return AppColors.purple;
      case 'Bibliothécaire': return AppColors.success;
      case 'Logé': return AppColors.gold;
      default: return AppColors.accent;
    }
  }
  Color get _roleBg {
    switch (user.role) {
      case 'Administrateur': return AppColors.purpleSoft;
      case 'Bibliothécaire': return AppColors.successSoft;
      case 'Logé': return AppColors.goldSoft;
      default: return AppColors.accentSoft;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_roleColor.withValues(alpha: 0.6), _roleColor]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(_initials(user.fullName), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(user.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _chip(user.role, _roleColor, _roleBg),
                      const SizedBox(width: 6),
                      _chip(user.isActive ? 'Actif' : 'Suspendu', user.isActive ? AppColors.success : AppColors.error, user.isActive ? AppColors.successSoft : AppColors.errorSoft),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: onViewDetail,
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(8)), child: const Text('Voir', style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onToggleActive,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: user.isActive ? AppColors.errorSoft : AppColors.successSoft, borderRadius: BorderRadius.circular(8)),
                    child: Text(user.isActive ? 'Suspendre' : 'Activer', style: TextStyle(color: user.isActive ? AppColors.error : AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _chip(String text, Color color, Color bg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      );

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _UserDetailSheet extends StatefulWidget {
  final UserModel user;
  const _UserDetailSheet({required this.user});
  @override
  State<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends State<_UserDetailSheet> {
  late String _selectedRole;
  @override
  void initState() { super.initState(); _selectedRole = widget.user.role; }

  Future<void> _changeRole(String newRole) async {
    await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({'role': newRole});
    setState(() => _selectedRole = newRole);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rôle mis à jour'), backgroundColor: AppColors.success));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(widget.user.fullName, style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.user.email, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            const Text('Changer le rôle', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: ['Logé', 'Externe', 'Bibliothécaire', 'Administrateur'].map((role) {
                final active = role == _selectedRole;
                return GestureDetector(
                  onTap: () => _changeRole(role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: active ? AppColors.purple : AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
                    child: Text(role, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.user.email);
                if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📧 Email de réinitialisation envoyé'), backgroundColor: AppColors.success)); }
              },
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.warning.withValues(alpha: 0.4))),
                child: const Center(child: Text('🔑 Réinitialiser le mot de passe', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600))),
              ),
            ),
          ],
        ),
      );
}

class _CreateStaffSheet extends StatefulWidget {
  const _CreateStaffSheet();
  @override
  State<_CreateStaffSheet> createState() => _CreateStaffSheetState();
}

class _CreateStaffSheetState extends State<_CreateStaffSheet> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'Bibliothécaire';
  bool _saving = false;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _create() async {
    setState(() => _saving = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailCtrl.text.trim(), password: _passCtrl.text.trim());
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'fullName': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'role': _role,
        'isLodged': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Compte créé'), backgroundColor: AppColors.success)); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Créer un compte staff', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _field('Nom complet', _nameCtrl),
            _field('Email', _emailCtrl),
            _field('Mot de passe', _passCtrl, obscure: true),
            const Text('Rôle', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: ['Bibliothécaire', 'Administrateur'].map((r) {
                final active = _role == r;
                return GestureDetector(
                  onTap: () => setState(() => _role = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(color: active ? AppColors.purple : AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
                    child: Text(r, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _saving ? null : _create,
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.purple, AppColors.accent]), borderRadius: BorderRadius.circular(14)),
                child: Center(child: _saving ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Créer le compte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
            ),
          ],
        ),
      );

  Widget _field(String label, TextEditingController ctrl, {bool obscure = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: ctrl,
              obscureText: obscure,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: true, fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
      );
}
