import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/document_model.dart';
import '../../providers/documents_provider.dart';
import '../../providers/admin_providers.dart';

class AdminDocumentsScreen extends ConsumerStatefulWidget {
  const AdminDocumentsScreen({super.key});
  @override
  ConsumerState<AdminDocumentsScreen> createState() => _AdminDocumentsScreenState();
}

class _AdminDocumentsScreenState extends ConsumerState<AdminDocumentsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final allDocs = ref.watch(documentsProvider).value ?? [];
    final query = ref.watch(adminDocSearchProvider);
    final filtered = query.isEmpty ? allDocs : allDocs.where((d) => d.title.toLowerCase().contains(query.toLowerCase()) || d.author.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Documents', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.bold))),
                  GestureDetector(
                    onTap: () => _showDocForm(context, null),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.accent, AppColors.purple]), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
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
                onChanged: (v) => ref.read(adminDocSearchProvider.notifier).set(v),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Rechercher...', hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                  filled: true, fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 6),
              child: Align(alignment: Alignment.centerLeft, child: Text('${filtered.length} document(s)', style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('Aucun document', style: TextStyle(color: AppColors.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _DocItem(
                        doc: filtered[i],
                        onEdit: () => _showDocForm(context, filtered[i]),
                        onDelete: () => _confirmDelete(context, filtered[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocForm(BuildContext context, DocumentModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DocFormSheet(existing: existing),
    );
  }

  void _confirmDelete(BuildContext context, DocumentModel doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Supprimer ce document ?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('"${doc.title}" — Cette action est irréversible.', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () async { Navigator.pop(context); await deleteDocument(doc.id); },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _DocItem extends StatelessWidget {
  final DocumentModel doc;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _DocItem({required this.doc, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Container(
              width: 50, height: 62,
              decoration: BoxDecoration(gradient: LinearGradient(colors: doc.gradientColors), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(doc.categoryEmoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${doc.author} · ${doc.year} · ${doc.totalCopies} ex.', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: doc.isAvailable ? AppColors.successSoft : AppColors.errorSoft, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          doc.isAvailable ? '${doc.availableCopies} dispo' : 'Indispo',
                          style: TextStyle(color: doc.isAvailable ? AppColors.success : AppColors.error, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(8)), child: const Text('✏️', style: TextStyle(fontSize: 12))),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppColors.errorSoft, borderRadius: BorderRadius.circular(8)), child: const Text('🗑', style: TextStyle(fontSize: 12))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DocFormSheet extends StatefulWidget {
  final DocumentModel? existing;
  const _DocFormSheet({this.existing});
  @override
  State<_DocFormSheet> createState() => _DocFormSheetState();
}

class _DocFormSheetState extends State<_DocFormSheet> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _copiesCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'book';
  bool _saving = false;

  static const _categories = [('book', '📘 Livre'), ('magazine', '🗞️ Magazine'), ('dvd', '💿 DVD'), ('pedagogical', '📋 Pédagogique')];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final d = widget.existing!;
      _titleCtrl.text = d.title;
      _authorCtrl.text = d.author;
      _yearCtrl.text = d.year.toString();
      _copiesCtrl.text = d.totalCopies.toString();
      _descCtrl.text = d.description;
      _category = d.category;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _authorCtrl.dispose(); _yearCtrl.dispose(); _copiesCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final data = {
      'title': _titleCtrl.text.trim(),
      'author': _authorCtrl.text.trim(),
      'category': _category,
      'year': int.tryParse(_yearCtrl.text) ?? 2024,
      'totalCopies': int.tryParse(_copiesCtrl.text) ?? 1,
      'description': _descCtrl.text.trim(),
    };
    try {
      if (widget.existing == null) {
        await addDocument(data);
      } else {
        await updateDocument(widget.existing!.id, data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(widget.existing == null ? 'Ajouter un document' : 'Modifier le document', style: GoogleFonts.playfairDisplay(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _Field(label: 'Titre', ctrl: _titleCtrl),
            _Field(label: 'Auteur', ctrl: _authorCtrl),
            const SizedBox(height: 4),
            const Text('Catégorie', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _categories.map((c) {
                final active = _category == c.$1;
                return GestureDetector(
                  onTap: () => setState(() => _category = c.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: active ? AppColors.accent : AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10)),
                    child: Text(c.$2, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _Field(label: 'Année', ctrl: _yearCtrl, number: true)), const SizedBox(width: 12), Expanded(child: _Field(label: 'Exemplaires', ctrl: _copiesCtrl, number: true))]),
            _Field(label: 'Description', ctrl: _descCtrl, maxLines: 3),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.accent, AppColors.purple]), borderRadius: BorderRadius.circular(14)),
                child: Center(child: _saving ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool number;
  final int maxLines;
  const _Field({required this.label, required this.ctrl, this.number = false, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: ctrl,
              keyboardType: number ? TextInputType.number : TextInputType.text,
              maxLines: maxLines,
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
